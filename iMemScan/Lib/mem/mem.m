//
//  mem.c
//  mem
//
//  Created by Liu Junqi on 3/23/18.
//  Copyright © 2018 DeviLeo. All rights reserved.
//

#include "mem.h"
#include "mem_utils.h"
#include <time.h>
#include <pthread.h>
#import "VMTool.h"
#import "JHLog.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR // Imports from /usr/lib/system/libsystem_kernel.dylib
// xnu-4570.1.46/osfmk/vm/vm_user.c
// http://www.newosxbook.com/src.jl?tree=listings&file=12-1-vmmap.c

/*
 * Do NOT use mach_vm_read, it will cause memory leak.
 * Use mach_vm_read_overwrite instead.
 */
extern kern_return_t
mach_vm_read(
             vm_map_t               map,
             mach_vm_address_t      addr,
             mach_vm_size_t         size,
             pointer_t              *data,
             mach_msg_type_number_t *data_size);

extern kern_return_t
mach_vm_read_overwrite(
                       vm_map_t           target_task,
                       mach_vm_address_t  address,
                       mach_vm_size_t     size,
                       mach_vm_address_t  data,
                       mach_vm_size_t     *outsize);

extern kern_return_t
mach_vm_write(
              vm_map_t                          map,
              mach_vm_address_t                 address,
              pointer_t                         data,
              __unused mach_msg_type_number_t   size);

extern kern_return_t
mach_vm_region(
               vm_map_t                 map,
               mach_vm_offset_t         *address,       /* IN/OUT */
               mach_vm_size_t           *size,          /* OUT */
               vm_region_flavor_t       flavor,         /* IN */
               vm_region_info_t         info,           /* OUT */
               mach_msg_type_number_t   *count,         /* IN/OUT */
               mach_port_t              *object_name);  /* OUT */

extern kern_return_t
mach_vm_region_recurse(
                       vm_map_t                 map,
                       mach_vm_address_t        *address,
                       mach_vm_size_t           *size,
                       uint32_t                 *depth,
                       vm_region_recurse_info_t info,
                       mach_msg_type_number_t   *infoCnt);

extern kern_return_t
mach_vm_protect(
                vm_map_t            map,
                mach_vm_offset_t    start,
                mach_vm_size_t      size,
                boolean_t           set_maximum,
                vm_prot_t           new_protection);

#else
#include <mach/mach_vm.h>
#endif

void all_processes(int uid) {
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    u_int miblen = 4;
    size_t size;
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    struct kinfo_proc *process = malloc(size);
    st = sysctl(mib, miblen, process, &size, NULL, 0);
    if (st == 0) {
        size_t count = (size / sizeof(struct kinfo_proc));
        if (count == 0) {
            NSLog(@"memlog: No process.\n");
        } else {
            NSLog(@"memlog: [pid] <uid:gid> name\n");
            for (size_t i = count - 1; i > 0; --i) {
                struct kinfo_proc proc = *(process + i);
                uid_t ruid = proc.kp_eproc.e_pcred.p_ruid;
                if ((uid == -1 && ruid < 500) ||
                    (uid >= 0 && ruid != uid)) continue;
                NSLog(@"memlog: [%d] <%d:%d> %s\n", proc.kp_proc.p_pid,
                      proc.kp_eproc.e_pcred.p_ruid, proc.kp_eproc.e_pcred.p_rgid,
                      proc.kp_proc.p_comm);
            }
        }
    } else {
        NSLog(@"memlog: Failed to fetch process. ret: %d, errno: %d\n", st, errno);
    }
    
    free(process);
}

mach_port_t get_task(int pid, NSString* name) {
    mach_port_t task = 0;
    //    NSString *log = nil;
    
    //    log = [NSString stringWithFormat:@"------ Getting. PID:%d ------",pid];
    //    kJHCacheLog(log)
    
    kern_return_t ret = task_for_pid(mach_task_self(), pid, &task);
    if (ret != KERN_SUCCESS) {
        
        NSString *pidStr = [NSString stringWithFormat:@"pid: %d", pid];
        NSString *nameStr = [NSString stringWithFormat:@"%@链接进程失败", name];
        
        UIAlertController *alertview = [UIAlertController alertControllerWithTitle:pidStr message:nameStr preferredStyle:UIAlertControllerStyleAlert];
        
        [alertview addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [[UIApplication sharedApplication].windows[0].rootViewController presentViewController:alertview animated:YES completion:nil];
        
        //        log = [NSString stringWithFormat:@"------ Connection FAIL. task:%s ------", mach_error_string(ret)];
        //        kJHCacheLog(log)
        //        [[JHLog share] save];
    }
    
    //    log = [NSString stringWithFormat:@"------ Connection Success. task:%d ------",task];
    //    kJHCacheLog(log)
    //    [[JHLog share] save];
    
    return task;
}

vm_map_offset_t get_base_address(mach_port_t task) {
    printf("Getting base address...");
    vm_map_offset_t vmoffset = 0;
    vm_map_size_t vmsize = 0;
    uint32_t nesting_depth = 0;
    struct vm_region_submap_info_64 vbr;
    mach_msg_type_number_t vbrcount = 16;
    kern_return_t kret = mach_vm_region_recurse(task, &vmoffset, &vmsize, &nesting_depth, (vm_region_recurse_info_t)&vbr, &vbrcount);
    if (kret == KERN_SUCCESS) {
        printf("%016llX %lld bytes.\n", vmoffset, vmsize);
    } else {
        printf("FAIL.\n");
    }
    return vmoffset;
}

void read_mem(mach_port_t task) {
    mach_vm_offset_t address = 0;
    mach_vm_size_t region_size = 0;
    vm_region_flavor_t flavor = VM_REGION_BASIC_INFO_64;
    mach_port_t object_name = 0;
    vm_region_basic_info_data_64_t info;
    mach_msg_type_number_t info_count = VM_REGION_BASIC_INFO_COUNT_64;
    
    kern_return_t kret = mach_vm_region(task, &address, &region_size, flavor, (vm_region_info_t)&info, &info_count, &object_name);
    while (kret == KERN_SUCCESS) {
        vm_prot_t protection = info.protection;
        
        char r = (protection & VM_PROT_READ) ? 'r' : '-';
        char w = (protection & VM_PROT_WRITE) ? 'w' : '-';
        char x = (protection & VM_PROT_EXECUTE) ? 'x' : '-';
        printf("Region: %016llX %c%c%c %llu bytes\n", address, r, w, x, region_size);
        
        void *data = malloc(region_size);
        mach_vm_size_t data_size = 0;
        kern_return_t kret_read = mach_vm_read_overwrite(task, address, region_size, (mach_vm_address_t)data, &data_size);
        if (kret_read == KERN_SUCCESS) {
            print_mem(data, data_size);
        }
        address += region_size;
        kret = mach_vm_region(task, &address, &region_size, flavor, (vm_region_info_t)&info, &info_count, &object_name);
    }
}

void *read_range_mem(mach_port_t task, mach_vm_address_t address, int forward, int backward, mach_vm_address_t *ret_address, mach_vm_size_t *ret_data_size) {
    mach_vm_offset_t region_address = address < forward ? address : address - forward;
    mach_vm_size_t region_size = 0;
    vm_region_flavor_t flavor = VM_REGION_BASIC_INFO_64;
    mach_port_t object_name = 0;
    vm_region_basic_info_data_64_t info;
    mach_msg_type_number_t info_count = VM_REGION_BASIC_INFO_COUNT_64;
    
    kern_return_t kret = mach_vm_region(task, &region_address, &region_size, flavor, (vm_region_info_t)&info, &info_count, &object_name);
    if (kret == KERN_SUCCESS) {
        mach_vm_address_t a = 0;
        mach_vm_size_t f = 0;
        mach_vm_size_t b = 0;
        if ((address < region_address) ||
            (address > region_address + region_size) ||
            (forward == 0 && backward == 0)) {
            f = 0;
            b = (region_size < backward || backward == 0) ? region_size : backward;
            a = region_address;
        } else {
            f = address - region_address;
            if (f > forward) f = forward;
            b = region_address + region_size - address;
            if (b > backward) b = backward;
            a = address - f;
        }
        
        mach_vm_size_t size = f + b;
        void *data = malloc(size);
        mach_vm_size_t data_size = 0;
        kern_return_t kret_read = mach_vm_read_overwrite(task, a, size, (mach_vm_address_t)data, &data_size);
        if (kret_read == KERN_SUCCESS) {
            if (ret_address) *ret_address = a;
            if (ret_data_size) *ret_data_size = data_size;
            return data;
        }
    }
    return NULL;
}

int read_region(mach_port_t task, mach_vm_address_t address, vm_region_basic_info_data_64_t *region_info) {
    mach_vm_size_t region_size = 0;
    vm_region_flavor_t flavor = VM_REGION_BASIC_INFO_64;
    mach_port_t object_name = 0;
    vm_region_basic_info_data_64_t info;
    mach_msg_type_number_t info_count = VM_REGION_BASIC_INFO_COUNT_64;
    
    kern_return_t kret = mach_vm_region(task, &address, &region_size, flavor, (vm_region_info_t)&info, &info_count, &object_name);
    if (kret != KERN_SUCCESS) return -1;
    if (region_info) *region_info = info;
    
    return 1;
}

int write_mem(mach_port_t task, mach_vm_address_t address, void *value, int size) {
    kern_return_t kret = mach_vm_write(task, address, (pointer_t)value, size);
    if (kret != KERN_SUCCESS) { task_resume(task); return -1; }
    return 1;
}

static long get_timestamp() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

search_result_chain_t search_mem_first(mach_port_t task, void *value, int size, int type, int comparison, int *length) {
    __block long begin_time  = get_timestamp();
    __block search_result_chain_t head_chain = NULL;
    __block search_result_chain_t chain = NULL;
    
    __block mach_vm_offset_t address = [[VMTool share] addrLowValue];
    __block mach_vm_size_t region_size = 0;
    __block vm_region_flavor_t flavor = VM_REGION_BASIC_INFO_64;
    __block mach_port_t object_name = 0;
    __block vm_region_basic_info_data_64_t info;
    __block mach_msg_type_number_t info_count = VM_REGION_BASIC_INFO_COUNT_64;
    __block dispatch_semaphore_t updateChain = dispatch_semaphore_create(1);
    
    __block int count = 0;
    __block kern_return_t kret = KERN_FAILURE;
    static NSUInteger max_thread_count = 50;
    __block dispatch_semaphore_t thread_semaphore = dispatch_semaphore_create(max_thread_count);
    
    do {
        @autoreleasepool {
            // 信号量用掉1个值
            dispatch_semaphore_wait(thread_semaphore, DISPATCH_TIME_FOREVER);
            address += region_size;
            kret = mach_vm_region(task, &address, &region_size, flavor, (vm_region_info_t)&info, &info_count, &object_name);
            if (kret != KERN_SUCCESS) {
                // 信号量用释放1个值
                dispatch_semaphore_signal(thread_semaphore);
                break;
            }
            
            if (!(info.protection & VM_PROT_WRITE)) {
                dispatch_semaphore_signal(thread_semaphore);
                continue;
            }
            
            __block void *data = (void*)malloc(region_size);
            __block mach_vm_size_t data_size = 0;
            
            // 这个部分，用同步子线程能加速。用异步线程难管理，且该方法异步容易挂
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    kern_return_t kret_read = mach_vm_read_overwrite(task, address, region_size, (mach_vm_address_t)data, &data_size);
                    if (kret_read != KERN_SUCCESS) {
                        free(data);
                        data = NULL;
                    }
                }
            });
            
            if (data == NULL) {
                dispatch_semaphore_signal(thread_semaphore);
                continue;
            }
            
            mach_vm_offset_t curAddress = address;
            
            // 异步判断
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    void *result = NULL;
                    int64_t big_size = data_size;
                    void *big = data;
                    do {
                        result = search_mem_value(big, big_size, value, size, type, comparison);
                        if (result == NULL) {
                            break;
                        }
                        mach_vm_address_t result_address_slide = (mach_vm_address_t)result - (mach_vm_address_t)data;
                        mach_vm_address_t result_address = curAddress + result_address_slide;
                        big = result + size;
                        big_size = data_size - result_address_slide - size;
                        
                        if (result_address > [[VMTool share] addrUppValue] || count > [[VMTool share] limitCount]) {
                            break;
                        }
                        dispatch_sync(dispatch_get_global_queue(DISPATCH_TARGET_QUEUE_DEFAULT, 0), ^{
                            search_result_chain_t c = create_search_result_chain(result_address, value, size, type, info.protection);
                            dispatch_semaphore_wait(updateChain, DISPATCH_TIME_FOREVER);
                            count++;
                            
                            if (head_chain == NULL) head_chain = c;
                            if (chain) chain->next = c;
                            
                            chain = c;
                            dispatch_semaphore_signal(updateChain);
                        });
                    } while (big_size >= size);
                    
                    free(data);
                    data = NULL;
                    dispatch_semaphore_signal(thread_semaphore);
                }
            });
        }
    } while (1);
    
    // 下面两个循环，确保创建的 20个信号量值，全部有释放，确保所有线程都有执行完
    for (int index = 0; index < max_thread_count; index++) {
        dispatch_semaphore_wait(thread_semaphore, DISPATCH_TIME_FOREVER);
    }
    for (int index = 0; index < max_thread_count; index++) {
        dispatch_semaphore_signal(thread_semaphore);
    }
    
    if (length) *length = count;
    long end_time = get_timestamp();
    NSLog(@"memlog: 搜索耗时: %.3f(s)",(float)(end_time - begin_time)/1000.0f);
    
    return head_chain;
}

search_result_chain_t search_mem_in_chain(mach_port_t task, void *value, int size, int type, int comparison, search_result_chain_t chain, int *length) {
    int count = 0;
    search_result_chain_t head_chain = chain;
    search_result_chain_t prev_chain = NULL;
    void *data = malloc(size);
    while (chain) {
        int destroy_chain = 1;
        if (chain->result) {
            mach_vm_offset_t address = chain->result->address;
            mach_vm_size_t data_size = 0;
            kern_return_t kret_read = mach_vm_read_overwrite(task, address, size, (mach_vm_address_t)data, &data_size);
            if (kret_read == KERN_SUCCESS) {
                int r = compare_value(data, (int)data_size, value, size, type);
                int match = (comparison == SearchResultComparisonLT && r == -1) ||
                (comparison == SearchResultComparisonLE && (r == -1 || r == 0)) ||
                (comparison == SearchResultComparisonEQ && r == 0) ||
                (comparison == SearchResultComparisonGE && (r == 0 || r == 1)) ||
                (comparison == SearchResultComparisonGT && r == 1);
                if (match) {
                    destroy_chain = 0;
                    //                    memcpy(chain->result->value, data, data_size);
                    // Modify by innovator
                    if (type == SearchResultValueTypeUInt8) {
                        uint8_t vv = *(uint8_t *)(data);
                        chain->result->value.uint8Value = vv;
                    } else if (type == SearchResultValueTypeSInt8) {
                        int8_t vv = *(int8_t *)(data);
                        chain->result->value.sint8Value = vv;
                    } else if (type == SearchResultValueTypeUInt16) {
                        uint16_t vv = *(uint16_t *)(data);
                        chain->result->value.uint16Value = vv;
                    } else if (type == SearchResultValueTypeSInt16) {
                        int16_t vv = *(int16_t *)(data);
                        chain->result->value.sint16Value = vv;
                    } else if (type == SearchResultValueTypeUInt32) {
                        uint32_t vv = *(uint32_t *)(data);
                        chain->result->value.uint32Value = vv;
                    } else if (type == SearchResultValueTypeSInt32) {
                        int32_t vv = *(int32_t *)(data);
                        chain->result->value.sint32Value = vv;
                    } else if (type == SearchResultValueTypeUInt64) {
                        uint64_t vv = *(uint64_t *)(data);
                        chain->result->value.uint64Value = vv;
                    } else if (type == SearchResultValueTypeSInt64) {
                        int64_t vv = *(int64_t *)(data);
                        chain->result->value.sint64Value = vv;
                    } else if (type == SearchResultValueTypeFloat) {
                        float vv = *(float *)(data);
                        chain->result->value.floatValue = vv;
                    } else if (type == SearchResultValueTypeDouble) {
                        double vv = *(double *)(data);
                        chain->result->value.doubleValue = vv;
                    }
                    ++count;
                }
            }
        }
        
        if (destroy_chain == 1) {
            if (prev_chain == NULL) {
                head_chain = chain->next;
                destroy_search_result_chain(chain);
                chain = head_chain;
            } else {
                prev_chain->next = chain->next;
                destroy_search_result_chain(chain);
                chain = prev_chain->next;
            }
        } else {
            prev_chain = chain;
            chain = chain->next;
        }
    }
    free(data);
    if (length) *length = count;
    return head_chain;
}

void review_mem_in_chain(mach_port_t task, search_result_chain_t chain) {
    while (chain) {
        if (chain->result) {
            mach_vm_offset_t address = chain->result->address;
            void *data = malloc(chain->result->size);
            mach_vm_size_t data_size = 0;
            
            kern_return_t kret_read = mach_vm_read_overwrite(task, address, chain->result->size, (mach_vm_address_t)data, &data_size);
            if (kret_read == KERN_SUCCESS) {
                // Modify by innovator
                if (chain->result->type == SearchResultValueTypeUInt8) {
                    uint8_t vv = *(uint8_t *)(data);
                    chain->result->value.uint8Value = vv;
                } else if (chain->result->type == SearchResultValueTypeSInt8) {
                    int8_t vv = *(int8_t *)(data);
                    chain->result->value.sint8Value = vv;
                } else if (chain->result->type == SearchResultValueTypeUInt16) {
                    uint16_t vv = *(uint16_t *)(data);
                    chain->result->value.uint16Value = vv;
                } else if (chain->result->type == SearchResultValueTypeSInt16) {
                    int16_t vv = *(int16_t *)(data);
                    chain->result->value.sint16Value = vv;
                } else if (chain->result->type == SearchResultValueTypeUInt32) {
                    uint32_t vv = *(uint32_t *)(data);
                    chain->result->value.uint32Value = vv;
                } else if (chain->result->type == SearchResultValueTypeSInt32) {
                    int32_t vv = *(int32_t *)(data);
                    chain->result->value.sint32Value = vv;
                } else if (chain->result->type == SearchResultValueTypeUInt64) {
                    uint64_t vv = *(uint64_t *)(data);
                    chain->result->value.uint64Value = vv;
                } else if (chain->result->type == SearchResultValueTypeSInt64) {
                    int64_t vv = *(int64_t *)(data);
                    chain->result->value.sint64Value = vv;
                } else if (chain->result->type == SearchResultValueTypeFloat) {
                    float vv = *(float *)(data);
                    chain->result->value.floatValue = vv;
                } else if (chain->result->type == SearchResultValueTypeDouble) {
                    double vv = *(double *)(data);
                    chain->result->value.doubleValue = vv;
                }
                //                memcpy(chain->result->value, data, data_size);
            }
            free(data);
        }
        chain = chain->next;
    }
}

search_result_chain_t search_mem(mach_port_t task, void *value, int size, int type, int comparison, search_result_chain_t chain, int *length) {
    search_result_chain_t result = NULL;
    if (chain == NULL) result = search_mem_first(task, value, size, type, comparison, length);
    else result = search_mem_in_chain(task, value, size, type, comparison, chain, length);
    return result;
}

void print_mem(void *data, mach_vm_size_t data_size) {
    for (mach_vm_size_t i = 0; i < data_size; ++i) {
        if (i % 16 == 0) {
            printf("\n%016llX ", (pointer_t)data + i);
        }
        printf("%02X ", *(unsigned char *)(data+i));
    }
}

search_result_chain_t near_mem_search_func(mach_port_t task,void *value,int size,int type,search_result_chain_t chain,int *length,int range)
{
    int haveresult = 0;
    int count = 0;
    search_result_chain_t head_chain = NULL;
    search_result_chain_t new_chain = NULL;
    //NSString *log = nil;
    
    while(chain){
    loop1: if (chain->result) {
        mach_vm_address_t addr = chain->result->address;
        mach_vm_size_t data_size = 0;
        mach_vm_address_t data_addr = 0;
        vm_region_basic_info_data_64_t info;
        
        int ret = read_region(task, chain->result->address, &info);
        if (ret !=1){
            chain = chain->next;
//                            log = [NSString stringWithFormat:@"region---------------------0.read_region 失败:%016llx, 下一个", chain->result->address];
//                            kJHCacheLog(log)
            goto loop1;
        }
        
        void *data = read_range_mem(task, addr, range, range+size, &data_addr, &data_size);
        if (data == NULL || data_size == 0) {
            chain = chain->next;
            //log = [NSString stringWithFormat:@"region---------------------1.read_range_mem 失败:%016llx, 下一个", chain->result->address];
            //kJHCacheLog(log)
            goto loop1;
        }
        
        void * result = NULL;
        void * big = data;
        int64_t big_size = data_size;
        do{
            result = search_mem_value(big, big_size, value, size, type, SearchResultComparisonEQ);
            if(result == NULL) {
                //log = [NSString stringWithFormat:@"region---------------------2.read_range_mem 失败:%016llx, 下一轮", chain->result->address];
                //kJHCacheLog(log)
                break;
            }
            
            count++;
            haveresult = 1;
            mach_vm_address_t result_address_slide = (mach_vm_address_t)result - (mach_vm_address_t)data;
            mach_vm_address_t result_realaddress = data_addr + result_address_slide;
            
            big = result + size;
            big_size = data_size - result_address_slide - size;
            
            search_result_chain_t c = create_search_result_chain(result_realaddress,value,size,type,info.protection);
            if (head_chain == NULL){
                head_chain = c;
            }
            if (new_chain){
                new_chain->next = c;
            }
            new_chain = c;
            
            //log = [NSString stringWithFormat:@"region---------------------3.create_search_result_chain 创建:%016llx", result_realaddress];
            //kJHCacheLog(log)
            
        }while(big_size >= size);
        
        if (haveresult == 1) {
            haveresult = 0;
            search_result_chain_t c2 = create_search_result_chain(chain->result->address, &(chain->result->value), chain->result->size, chain->result->type, chain->result->protection);
            new_chain->next = c2;
            new_chain = c2;
            ++count;
            
//            log = [NSString stringWithFormat:@"region---------------------4.create_search_result_chain 创建:%016llx", chain->result->address];
//            kJHCacheLog(log)
        }
        chain = chain->next;
        free(data);
    }
    }
    
    //[[JHLog share] save];
    
    destroy_all_search_result_chain(chain);
    if(length) *length = count;
    return head_chain;
}
