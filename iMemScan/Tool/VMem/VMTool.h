//
//  VMTool.h
//  ViewMem
//
//  Created by HaoCold on 2020/8/26.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMTypeHeader.h"

@class MemRecordModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^VMToolSearchBlock)(NSInteger count, NSArray *array);

@interface VMTool : NSObject

+ (instancetype)share;

- (void)setPid:(int)pid name:(NSString *)name;
- (mach_port_t)getTask;

//-(void)kais:(uint64_t)address bt:(NSString *)Bytes;

// 搜索
- (void)nearMemSearch:(NSString *)value type:(VMMemValueType)type range:(int)range callback:(VMToolSearchBlock)block;
- (void)searchValue:(NSString *)value type:(VMMemValueType)type comparison:(VMMemComparison)comparison callback:(VMToolSearchBlock)block;
- (void)modifyValue:(NSString *)value address:(NSString *)address type:(VMMemValueType)type;

- (void)reset;
- (void)refreshWithCallback:(VMToolSearchBlock)block;

// 查看内存
- (NSArray *)memory:(NSString *)address size:(NSString *)size type:(VMMemSearchType)type valueType:(VMMemValueType)valueType;

// 邻近范围
- (int)rangeValue;
- (NSString *)rangeStringValue;
- (void)setRange:(NSString *)range;

// 下限
- (uint64_t)addrLowValue;
- (NSString *)addrRange;
- (void)setAddrRange:(NSString *)low;

// 上限
- (uint64_t)addrUppValue;
- (NSString *)addrRangeUpp;
- (void)setAddrRangeUpp:(NSString *)Upp;

// 结果数里限制
- (void)setLimitCount:(NSString *)count;
- (NSInteger)limitCount;

// 定时修改
- (void)setDuration:(NSString *)duration;
- (NSInteger)duration;
- (void)setDuration1:(NSString *)duration;
- (NSInteger)duration1;

// 类型对应的 枚举
- (NSArray *)allKeys;
- (NSDictionary *)keyValues;


// 修改中
@property (nonatomic,  assign) BOOL  modifying;
// 一键修改
//- (void)oneKeyModify:(MemRecordModel *)model;
// 一键设置
- (void)oneKeySetup:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
