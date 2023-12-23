//
//  SetModel.h
//  iMemScan
//
//  Created by HaoCold on 2021/8/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SetModel : NSObject

@property (nonatomic,  assign) NSString *range;
@property (nonatomic,  assign) NSString *addrRangeStart;
@property (nonatomic,  assign) NSString *addrRangeEnd;
@property (nonatomic,  assign) NSString *LimitCount;
@property (nonatomic,  assign) NSString *duration;
@property (nonatomic,  assign) NSString *duration1;

+ (instancetype)share;
@end

NS_ASSUME_NONNULL_END
