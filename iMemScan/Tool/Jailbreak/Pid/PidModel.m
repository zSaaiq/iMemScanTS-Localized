//
//  PidModel.m
//  BeautyList
//
//  Created by HaoCold on 2020/11/23.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import "PidModel.h"
#import "NSTask.h"
#import "YYModel.h"
#import <UIKit/UIKit.h>
#import "JHLog.h"

@implementation PidModel

+ (NSArray *)refreshModelArray;
{
    NSTask *task = [NSTask new];
    [task setLaunchPath:@"/bin/ps"];
    [task setArguments:[NSArray arrayWithObjects:@"aux", nil, nil]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task launch];
    
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    [task waitUntilExit];
    
    NSString * string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    //NSLog(@"**** Result: %@", string);
    
    NSArray *array = [self modelArray:string];
//    NSString *json = [array yy_modelToJSONString];
//    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"pidlog.txt"];
//    [json writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL];

//    [self showText:json];
    
    return array;
}

+ (NSArray *)modelArray:(NSString *)input
{
    NSString *str = input;
    
    NSArray *arr = [str componentsSeparatedByString:@"\n"];
    //NSLog(@"arr = %@", @(arr.count));
    
    NSMutableArray *marr = @[].mutableCopy;
    NSMutableArray *marr1 = @[].mutableCopy;
    NSString *pre = @" /var/containers/Bundle/Application/";
    NSString *pre1 = @" /Applications/";
    for (NSString *s in arr) {
        if ([s containsString:pre]) {
            [marr addObject:s];
        }else if ([s containsString:pre1]) {
            [marr1 addObject:s];
        }
    }
    
    //NSLog(@"marr = %@", @(marr.count));
    
    // 用户程序
    NSArray *arr1 = [self getModel:marr pre:pre];
    // 系统
    NSArray *arr2 = [self getModel:marr1 pre:pre1];
    
    return @[arr1, arr2];
}

/*
 NSString *log = nil;
 log = [NSString stringWithFormat:@"strs = %@", strs];
 kJHCacheLog(log)
 [[JHLog share] save];
 */

+ (NSArray *)getModel:(NSArray *)marr pre:(NSString *)pre
{
    NSMutableArray *result = @[].mutableCopy;
    for (NSString *s in marr) {
        NSArray *arr = [NSMutableArray arrayWithArray:[s componentsSeparatedByString:pre]];
        
        NSMutableArray *strs = [arr[0] componentsSeparatedByString:@" "].mutableCopy;
        [strs removeObject:@""];
        //NSLog(@"strs = %@", strs);
        
        NSString *name = [[arr[1] componentsSeparatedByString:@".app/"] lastObject];
        if ([name containsString:@"/"]) {
            break;
        }
        
        //
        PidModel *model = [[PidModel alloc] init];
        model.name = name;
        model.pid = strs[1];
        
        [result addObject:model];
    }
    return result;
}

+ (void)showText:(NSString *)text
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:text preferredStyle:UIAlertControllerStyleAlert];
    [[UIApplication sharedApplication].windows[0].rootViewController presentViewController:alert animated:YES completion:nil];
}

@end
