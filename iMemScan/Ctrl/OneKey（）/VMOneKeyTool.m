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

NSMutableArray *_allData;

@implementation VMOneKeyTool

+ (void)setup
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:kPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:doc withIntermediateDirectories:YES attributes:nil error:nil];
            [[NSFileManager defaultManager] createFileAtPath:kPath contents:nil attributes:nil];
        }
        
        NSArray *array = @[];
        NSString *string = [[NSString alloc] initWithContentsOfFile:kPath encoding:NSUTF8StringEncoding error:NULL];
        //NSLog(@"*** string = %@",string);
        if (string.length > 0) {
            array = [NSArray yy_modelArrayWithClass:[VMOneKeyModel class] json:string];
        }
        _allData = @[].mutableCopy;
        if (array.count > 0) {
            [_allData addObjectsFromArray:array];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:UIApplicationWillTerminateNotification object:nil];
    });
}

+ (NSArray *)allRecords
{
    return [NSArray arrayWithArray:_allData];
}

+ (void)deleteRecord:(VMOneKeyModel *)model
{
    [_allData removeObject:model];
}

+ (void)saveRecord:(VMOneKeyModel *)model
{
    [_allData addObject:model];
}

+ (void)save
{
    NSString *string = [_allData yy_modelToJSONString];
    [string writeToFile:kPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

+ (void)exchange:(NSInteger)idx1 index:(NSInteger)idx2
{
    [_allData exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

@end
