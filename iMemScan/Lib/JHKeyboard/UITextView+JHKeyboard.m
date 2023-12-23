//
//  UITextView+JHKeyboard.m
//  JHKeyboard
//
//  Created by HaoCold on 2020/8/18.
//  Copyright © 2020 HaoCold. All rights reserved.
//
//  Copyright (c) 2020 xjh093
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

#import "UITextView+JHKeyboard.h"
#import <objc/runtime.h>

@implementation UITextView (JHKeyboard)

- (JHKeyboard *)jh_keyboard{
    JHKeyboard *keyboard = objc_getAssociatedObject(self, _cmd);
    if (!keyboard) {
        keyboard = [[JHKeyboard alloc] init];
        [keyboard setValue:self forKey:@"textView"];
        self.jh_keyboard = keyboard;
    }
    return keyboard;
}

- (void)setJh_keyboard:(JHKeyboard *)jh_keyboard{
    objc_setAssociatedObject(self, @selector(jh_keyboard), jh_keyboard, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
