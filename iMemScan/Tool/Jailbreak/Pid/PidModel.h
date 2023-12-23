//
//  PidModel.h
//  BeautyList
//
//  Created by HaoCold on 2020/11/23.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PidModel : NSObject

@property (nonatomic,    copy) NSString *name;
@property (nonatomic,    copy) NSString *pid;
@property (nonatomic,  assign) BOOL  selected;

+ (NSArray *)modelArray:(NSString *)input;
+ (NSArray *)refreshModelArray;
@end

NS_ASSUME_NONNULL_END
