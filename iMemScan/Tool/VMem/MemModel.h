//
//  MemModel.h
//  ViewMem
//
//  Created by HaoCold on 2020/8/27.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMTypeHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface MemModel : NSObject

@property (nonatomic) UInt64 o_addr;
@property (nonatomic,    copy) NSString *address;
@property (nonatomic,    copy) NSString *value;
@property (nonatomic,    copy) NSString *key;
@property (nonatomic,  assign) VMMemValueType  type;

// ===== 部分修改使用 =====
@property (nonatomic,  assign) BOOL  selected;
@property (nonatomic,  assign) NSInteger  index;

// ===== 储存记录使用 =====
@property (nonatomic,    copy) NSString *recordName;

// ===== 查看内存使用 =====
@property (nonatomic,  assign) VMMemValueType  valueType;
@property (nonatomic,    copy) NSString *value_16;
@property (nonatomic,    copy) NSString *value_10;


- (MemModel *)clone;

@end

NS_ASSUME_NONNULL_END
