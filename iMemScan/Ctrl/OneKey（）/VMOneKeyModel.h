//
//  VMOneKeyModel.h
//  MemView
//
//  Created by HaoCold on 2020/9/28.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VMOneKeySubType) {
    VMOneKeySubType_NumberSearch,   // 数值搜索
    VMOneKeySubType_NearRange,      // 邻近范围
    VMOneKeySubType_NearSearch,     // 邻近搜索
    VMOneKeySubType_Result,         // 修改结果
    VMOneKeySubType_Clear           // 清除结果
};

@interface VMOneKeyModel : NSObject
@property (nonatomic,    copy) NSString *name;
@property (nonatomic,  strong) NSMutableArray *steps;
@property (nonatomic,  assign) BOOL  open;
@end


@interface VMOneKeySubModel : NSObject

@property (nonatomic,    copy) NSString *name;
@property (nonatomic,  assign) VMOneKeySubType  type;
@property (nonatomic,    copy) NSString *typeName;

/// 类型(I8,I16,I32,I64,F32,F64)
@property (nonatomic,    copy) NSString *key;
/// 数值
@property (nonatomic,    copy) NSString *value;
/// 要修改的位置(-1,全部。1,3,第1个，第3个)
@property (nonatomic,    copy) NSString *indexs;
/// 通知开关
@property (nonatomic,  assign) BOOL switOpen;
/// 清除通知开关
@property (nonatomic,  assign) BOOL clearOpen;
/// 偏移量
@property (nonatomic,    copy) NSString *offset;
@end

NS_ASSUME_NONNULL_END
