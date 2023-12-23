//
//  JHLog.h
//  A
//
//  Created by HaoCold on 2020/11/4.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kJHCacheLog(log) [[JHLog share] cache:log];

@interface JHLog : NSObject

+ (instancetype)share;

- (void)cache:(NSString *)log;
- (void)save;
@end

NS_ASSUME_NONNULL_END
