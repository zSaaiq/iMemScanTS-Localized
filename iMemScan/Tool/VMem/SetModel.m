//
//  SetModel.m
//  iMemScan
//
//  Created by HaoCold on 2021/8/16.
//

#import <UIKit/UIKit.h>
#import "SetModel.h"
#import "YYModel.h"

@implementation SetModel

NSMutableArray *_setData;

+ (instancetype)share
{
    static SetModel *model;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[SetModel alloc] init];
    });
    return model;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

@end
