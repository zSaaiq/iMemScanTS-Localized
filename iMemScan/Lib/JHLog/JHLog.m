//
//  JHLog.m
//  A
//
//  Created by HaoCold on 2020/11/4.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import "JHLog.h"

@interface JHLog()
@property (nonatomic,  strong) NSString *path;
@property (nonatomic,  strong) NSMutableArray *logArray;
@property (nonatomic,  strong) NSDateFormatter *formatter;
@end

@implementation JHLog

+ (instancetype)share
{
    static JHLog *log;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        log = [[JHLog alloc] init];
    });
    return log;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _logArray = @[].mutableCopy;
        
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        // 这个路径改一下
//        _path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Memlog.txt"];
        
        _path = @"/var/mobile/Media/iMemScan(Script)/Memlog.txt";
    }
    
    return self;
}

- (void)cache:(NSString *)log
{
    if (log.length == 0) {
        return;
    }
    
    NSString *time  = [_formatter stringFromDate:[NSDate date]];
    log = [NSString stringWithFormat:@"%@\n%@",time,log];
    [_logArray addObject:log];
    
//    log = [NSString stringWithFormat:@"%@",log];
//    [_logArray addObject:log];
}

- (void)save
{
    NSString *log = [_logArray componentsJoinedByString:@"\n\n"];
    [log writeToFile:_path atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

@end
