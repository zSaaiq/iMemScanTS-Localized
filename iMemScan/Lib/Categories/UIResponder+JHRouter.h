//
//  UIResponder+JHRouter.h
//  JHKit
//
//  Created by HaoCold on 2017/12/7.
//  Copyright © 2017年 HaoCold. All rights reserved.
//
//  MIT License
//
//  Copyright (c) 2017 xjh093
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import <UIKit/UIKit.h>

@interface UIResponder (JHRouter)

/**
 if
 [object respondsToSelector:NSSelectorFromString(selector)]
 or
 [selector isEqualToString:@"xxx"]
 you should do something.
 
 if you override this method, see this example:
 
 @code
 - (void)jh_routerWithSelector:(NSString *)selector sender:(id)sender info:(NSDictionary *)info{
    if ([self respondsToSelector:NSSelectorFromString(selector)]){
        [self performSelector:NSSelectorFromString(selector) withObjects:info];
    }
    else if ([selector isEqualToString:@"xxx"]) {
        // do something with info.
    }
    else{
 
        // This is important!!!
        // if you can't handle it, pass it to nextResponder to handle it.
 
        [self.nextResponder jh_routerWithSelector:selector sender:sender info:info];
    }
 }
 
 @endcode
 
 */
- (void)jh_routerWithSelector:(NSString *)selector
                       sender:(id)sender
                         info:(NSDictionary *)info;

@end
