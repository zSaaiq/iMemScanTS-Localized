//
//  AppController.h
//  MemSearch
//
//  Created by 李良林 on 2020/10/18.
//  Copyright © 2020 李良林. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "App.h"

@interface AppController : NSObject

@property (nonatomic, readonly) NSArray* installedApplications;

- (BOOL)openAppWithBundleIdentifier:(NSString*)bundleIdentifier;
- (NSArray*)privateURLSchemes;
- (NSArray*)publicURLSchemes;
- (NSArray*)readApplications;

+ (instancetype)sharedInstance;

@end
