//
//  VMOneKeyModel.m
//  MemView
//
//  Created by HaoCold on 2020/9/28.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import "VMOneKeyModel.h"

@implementation VMOneKeyModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _steps = @[].mutableCopy;
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{@"steps": [VMOneKeySubModel class]};
}

+ (nullable NSArray<NSString *> *)modelPropertyBlacklist
{
    return @[@"open"];
}

@end

@implementation VMOneKeySubModel

@end
