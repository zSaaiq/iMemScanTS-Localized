//
//  VMOneKeyTool.m
//  MemView
//
//  Created by HaoCold on 2020/9/29.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import "VMOneKeyTool.h"
#import "YYModel.h"
#import "VMOneKeyModel.h"
#import <UIKit/UIKit.h>

#define doc [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"iMemScan(Script)"]

#define kPath [doc stringByAppendingPathComponent:@"recordData.data"]
#define kGroupPath [doc stringByAppendingPathComponent:@"groupData.data"]

NSMutableArray *_allData;
NSMutableArray *_groupData;

@implementation VMOneKeyTool

+ (void)setup
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:doc]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:doc withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:kPath]) {
            [[NSFileManager defaultManager] createFileAtPath:kPath contents:nil attributes:nil];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:kGroupPath]) {
            [[NSFileManager defaultManager] createFileAtPath:kGroupPath contents:nil attributes:nil];
        }
        
        _allData = @[].mutableCopy;
        _groupData = @[].mutableCopy;
        
        //
        [_allData addObjectsFromArray:[self setupData:kPath model:[VMOneKeyModel class]]];
        [_groupData addObjectsFromArray:[self setupData:kGroupPath model:[VMOneKeyGroupModel class]]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveAll) name:UIApplicationWillTerminateNotification object:nil];
    });
}

+ (NSArray *)setupData:(NSString *)path model:(Class)model
{
    NSArray *array = @[];
    NSString *string = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    //NSLog(@"*** string = %@",string);
    if (string.length > 0) {
        array = [NSArray yy_modelArrayWithClass:model json:string];
    }
    
    return array;
}

+ (void)saveAll
{
    [self save:VMOneKeyType_Record];
    [self save:VMOneKeyType_Group];
}

+ (NSArray *)allRecords:(VMOneKeyType)type
{
    if (type == VMOneKeyType_Record) {
        return [NSArray arrayWithArray:_allData];
    }else if (type == VMOneKeyType_Group) {
        return [NSArray arrayWithArray:_groupData];
    }
    return @[];
}

+ (void)deleteRecord:(VMOneKeyModel *)model
{
    [_allData removeObject:model];
}

+ (void)saveRecord:(VMOneKeyModel *)model
{
    [_allData addObject:model];
}

+ (void)save:(VMOneKeyType)type
{
    if (type == VMOneKeyType_Record) {
        NSString *string = [_allData yy_modelToJSONString];
        [string writeToFile:kPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }else if (type == VMOneKeyType_Group) {
        NSString *string = [_groupData yy_modelToJSONString];
        [string writeToFile:kGroupPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }
}

+ (void)exchange:(NSInteger)idx1 index:(NSInteger)idx2 type:(VMOneKeyType)type
{
    if (type == VMOneKeyType_Record) {
        [_allData exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
    }else if (type == VMOneKeyType_Group) {
        [_groupData exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
    }
}

+ (void)deleteGroup:(VMOneKeyGroupModel *)model
{
    // 移除对应记录
    NSInteger gid = model.gid;
    NSMutableArray *removes = @[].mutableCopy;
    for (VMOneKeyModel *m in _allData) {
        if (m.gid == gid) {
            [removes addObject:m];
        }
    }
    
    [_allData removeObjectsInArray:removes];
    
    // 移除组
    [_groupData removeObject:model];
}

+ (void)saveGroup:(VMOneKeyGroupModel *)model
{
    if (_groupData.count == 0) {
        model.gid = 0;
    }else{
        NSArray *gids = [_groupData valueForKey:@"gid"];
        NSInteger maxID = 0;
        for (NSNumber *num in gids) {
            NSInteger n = num.integerValue;
            maxID = maxID > n ? maxID : n;
        }
        model.gid = maxID + 1;
    }
    
    [_groupData addObject:model];
}

@end
