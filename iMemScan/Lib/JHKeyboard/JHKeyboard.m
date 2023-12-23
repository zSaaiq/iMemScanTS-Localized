//
//  JHKeyboard.m
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

#import "JHKeyboard.h"

@interface JHKeyboard()
@property (nonatomic,    weak) UITextView *textView;
@property (nonatomic,    weak) UITextField *textField;
@property (nonatomic,  assign) BOOL  textViewIsActive;
@property (nonatomic,  assign) BOOL  textFieldIsActive;
@end

@implementation JHKeyboard

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addNotification];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNoti:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNoti:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNoti:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNoti:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardNoti:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    if (_changeBlock) {
        NSNotificationName name = noti.name;
        if ([name isEqualToString:UIKeyboardWillShowNotification] || [name isEqualToString:UIKeyboardDidShowNotification]){
            if (_textView.isFirstResponder) {
                _textViewIsActive = YES;
                _changeBlock(noti.name, beginFrame, endFrame, duration, curve);
            }else if (_textField.isFirstResponder) {
                _textFieldIsActive = YES;
                _changeBlock(noti.name, beginFrame, endFrame, duration, curve);
            }
        }else{
            if (_textViewIsActive) {
                if ([name isEqualToString:UIKeyboardDidHideNotification]) {
                    _textViewIsActive = NO;
                }
                
                _changeBlock(noti.name, beginFrame, endFrame, duration, curve);
            }else if (_textFieldIsActive) {
                if ([name isEqualToString:UIKeyboardDidHideNotification]) {
                    _textFieldIsActive = NO;
                }
                
                _changeBlock(noti.name, beginFrame, endFrame, duration, curve);
            }
        }
    }
}

@end
