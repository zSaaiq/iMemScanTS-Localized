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
@class VMOneKeyGroupModel;

typedef NS_ENUM(NSUInteger, VMOneKeyType) {
    VMOneKeyType_Record,    // 记录
    VMOneKeyType_Group,     // 组
};

@interface VMOneKeyTool : NSObject

+ (void)setup;

+ (void)saveAll;
+ (NSArray *)allRecords:(VMOneKeyType)type;
+ (void)save:(VMOneKeyType)type;
+ (void)exchange:(NSInteger)idx1 index:(NSInteger)idx2 type:(VMOneKeyType)type;

// ================== 脚本 ==================
+ (void)deleteRecord:(VMOneKeyModel *)model;
+ (void)saveRecord:(VMOneKeyModel *)model;

// ================== 组 ==================
+ (void)deleteGroup:(VMOneKeyGroupModel *)model;
+ (void)saveGroup:(VMOneKeyGroupModel *)model;

@end

NS_ASSUME_NONNULL_END
