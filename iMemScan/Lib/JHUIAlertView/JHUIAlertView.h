//
//  JHUIAlertView.h
//  JHKit
//
//  Created by HaoCold on 2017/8/26.
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

@class JHUIAlertView,JHUIAlertConfig,JHUIAlertTextConfig,JHUIAlertButtonConfig;

typedef void(^JHUIAlertViewAddCustomViewBlock)(JHUIAlertView *alertView, CGRect contentViewRect, CGRect titleLabelRect, CGRect contentLabelRect);

@interface JHUIAlertView : UIView

@property (nonatomic,  strong,  readonly) UIView        *contentView;
@property (nonatomic,  strong,  readonly) UILabel       *titleLabel;
@property (nonatomic,  strong,  readonly) UILabel       *contentLabel;
@property (nonatomic,  strong,  readonly) NSArray       *buttonArray;
@property (nonatomic,  strong,  readonly) UIView        *titleBottomLine;

@property (nonatomic,  strong,  readonly) JHUIAlertConfig      *config;

@property (nonatomic,    copy) dispatch_block_t tapOutDismissBlock;

+ (void)jh_show_title:(NSString *)title
              message:(NSString *)message
               inView:(UIView *)view;

+ (void)jh_show_title:(NSString *)title
              message:(NSString *)message
               inView:(UIView *)view
          buttonTitle:(NSString *)buttonTitle
             andBlock:(dispatch_block_t)block;

+ (void)jh_show_title:(NSString *)title
              message:(NSString *)message
               inView:(UIView *)view
          buttonTitle:(NSString *)buttonTitle
             andBlock:(dispatch_block_t)block
         buttonTitle2:(NSString *)buttonTitle2
            andBlock2:(dispatch_block_t)block2;

- (instancetype)initWithConfig:(JHUIAlertConfig *)config;

/**
 
 @brief Add a custom view in 'JHUIAlertView'.
 
 @note If you want to add a custom view in 'contentView', you should keep enough sapce through use 'topPadding', 'bottomPadding' etc.
 
 @code
 
 JHUIAlertConfig *config    = [[JHUIAlertConfig alloc] init];
 config.title.text          = @"add custom view";
 config.title.bottomPadding = 40;  // use this to keep enough height
 
 JHUIAlertView *alertView = [[JHUIAlertView alloc] initWithConfig:config];
 
 [alertView addCustomView:^(JHUIAlertView *alertView, CGRect contentViewRect, CGRect titleLabelRect, CGRect contentLabelRect) {
 
     UILabel *label = [[UILabel alloc] init];
     label.frame = CGRectMake(0, CGRectGetMaxY(titleLabelRect)+10, contentViewRect.size.width, 20);
     label.text = @"This is a custom view";
     label.textColor = [UIColor blackColor];
     label.font = [UIFont systemFontOfSize:14];
     label.textAlignment = NSTextAlignmentCenter;
 
     [alertView.contentView addSubview:label];
 }];
 
 */
- (void)addCustomView:(JHUIAlertViewAddCustomViewBlock)block;

- (void)showInView:(UIView *)view;
- (void)dismiss;

@end

@interface JHUIAlertConfig : NSObject

/// title
@property (nonatomic,  strong,  readonly) JHUIAlertTextConfig      *title;
/// content
@property (nonatomic,  strong,  readonly) JHUIAlertTextConfig      *content;
/// the line between title and content, default is NO.
@property (assign,  nonatomic) BOOL              titleBottomLineHidden;
/// buttons
@property (strong,  nonatomic) NSArray<JHUIAlertButtonConfig *> *buttons;
/// the alpha of black mask view, default is 0.5
@property (assign,  nonatomic) CGFloat           blackViewAlpha;
/// show animation, default is YES
@property (nonatomic,  assign) BOOL              showAnimation;
/// show animation duration, default is 0.25s
@property (nonatomic,  assign) CGFloat           showAnimationDuration;
/// Default is: [UIScreen mainScreen].bounds.size.width - 100
@property (nonatomic,  assign) CGFloat           contentViewWidth;
/// Height for a fully custom view
@property (nonatomic,  assign) CGFloat           contentViewHeight;
/// Default is 10
@property (nonatomic,  assign) CGFloat           contentViewCornerRadius;
/// Default is YES
@property (nonatomic,  assign) BOOL              dismissWhenTapOut;
/// Button height
@property (nonatomic,  assign) CGFloat           buttonHeight;

@end

@interface JHUIAlertTextConfig : NSObject

/// text
@property (copy,    nonatomic) NSString         *text;
/// text color
@property (strong,  nonatomic) UIColor          *color;
/// text font, default is 18
@property (strong,  nonatomic) UIFont           *font;
/// top padding
@property (nonatomic,  assign) CGFloat           topPadding;
/// left padding
@property (nonatomic,  assign) CGFloat           leftPadding;
/// bottom padding
@property (nonatomic,  assign) CGFloat           bottomPadding;
/// right padding
@property (nonatomic,  assign) CGFloat           rightPadding;
/// auto height
@property (nonatomic,  assign) BOOL              autoHeight;
/// line space
@property (nonatomic,  assign) CGFloat           lineSpace;
/// max height (for content)
@property (nonatomic,  assign) CGFloat           maxHeight;
@end

@interface JHUIAlertButtonConfig : NSObject

/// title
@property (copy,    nonatomic) NSString         *title;
/// title color
@property (strong,  nonatomic) UIColor          *color;
/// title font, default is 18
@property (strong,  nonatomic) UIFont           *font;
/// image
@property (strong,  nonatomic) UIImage          *image;
/// the space between image and title
@property (nonatomic,  assign) CGFloat           imageTitleSpace;
/// block
@property (copy,    nonatomic) dispatch_block_t  block;

+ (JHUIAlertButtonConfig *)configWithTitle:(NSString *)title color:(UIColor *)color font:(UIFont *)font image:(UIImage *)image handle:(dispatch_block_t)block;

@end
