//
//  VMOneKeyTool.h
//  MemView
//
//  Created by HaoCold on 2020/9/29.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VMOneKeyModel;

@interface VMOneKeyTool : NSObject

+ (void)setup;
+ (NSArray *)allRecords;
+ (void)deleteRecord:(VMOneKeyModel *)model;
+ (void)saveRecord:(VMOneKeyModel *)model;
+ (void)save;
+ (void)exchange:(NSInteger)idx1 index:(NSInteger)idx2;

@end

NS_ASSUME_NONNULL_END
