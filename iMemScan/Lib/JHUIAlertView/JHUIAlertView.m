//
//  JHUIAlertView.m
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

#import "JHUIAlertView.h"
#import <Foundation/Foundation.h>

@interface JHUIAlertView()

@property (strong,  nonatomic) JHUIAlertConfig      *config;
@property (nonatomic,  assign) NSInteger  rotation;
@property (nonatomic,  assign) CGFloat  contentViewHeight;

@property (nonatomic,  strong) UIView *titleView;
@property (nonatomic,  strong) UIView *middleView;
@property (nonatomic,  strong) UIView *bottomView;

@end

@implementation JHUIAlertView

+ (void)jh_show_title:(NSString *)title
              message:(NSString *)message
               inView:(UIView *)view{
    JHUIAlertConfig *config = [[JHUIAlertConfig alloc] init];
    config.title.text       = title;
    config.content.text     = message;
    JHUIAlertView *alert    = [[JHUIAlertView alloc] initWithConfig:config];
    [view addSubview:alert];
}

+ (void)jh_show_title:(NSString *)title
              message:(NSString *)message
               inView:(UIView *)view
          buttonTitle:(NSString *)buttonTitle
             andBlock:(dispatch_block_t)block{
    JHUIAlertConfig *config = [[JHUIAlertConfig alloc] init];
    config.title.text       = title;
    config.content.text     = message;
    JHUIAlertButtonConfig *btnconfig1 = [JHUIAlertButtonConfig configWithTitle:buttonTitle color:nil font:nil image:nil handle:^{
        if (block) {
            block();
        }
    }];
    config.buttons = @[btnconfig1];
    JHUIAlertView *alert    = [[JHUIAlertView alloc] initWithConfig:config];
    [view addSubview:alert];
}

+ (void)jh_show_title:(NSString *)title
              message:(NSString *)message
               inView:(UIView *)view
          buttonTitle:(NSString *)buttonTitle
             andBlock:(dispatch_block_t)block
         buttonTitle2:(NSString *)buttonTitle2
            andBlock2:(dispatch_block_t)block2{
    JHUIAlertConfig *config = [[JHUIAlertConfig alloc] init];
    config.title.text       = title;
    config.content.text     = message;
    JHUIAlertButtonConfig *btnconfig1 = [JHUIAlertButtonConfig configWithTitle:buttonTitle color:nil font:nil image:nil handle:^{
        if (block) {
            block();
        }
    }];
    JHUIAlertButtonConfig *btnconfig2 = [JHUIAlertButtonConfig configWithTitle:buttonTitle2 color:nil font:nil image:nil handle:^{
        if (block2) {
            block2();
        }
    }];
    config.buttons = @[btnconfig1,btnconfig2];
    JHUIAlertView *alert    = [[JHUIAlertView alloc] initWithConfig:config];
    [view addSubview:alert];
}

- (instancetype)initWithConfig:(JHUIAlertConfig *)config{
    return [self initWithFrame:CGRectZero config:config];
}

- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:CGRectZero config:[[JHUIAlertConfig alloc] init]];
}

- (instancetype)initWithFrame:(CGRect)frame config:(JHUIAlertConfig *)config
{
    frame = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:frame];
    if (self) {
        _config = config;
        [self jhSetupViews:frame];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)jhSetupViews:(CGRect)frame
{
    
    if (_config.blackViewAlpha < 0 || _config.blackViewAlpha >0.8) {
        _config.blackViewAlpha = 0.5;
    }
    if (_config.contentViewWidth <= 0 ||
        _config.contentViewWidth > [UIScreen mainScreen].bounds.size.width) {
        _config.contentViewWidth = [UIScreen mainScreen].bounds.size.width - 100;
    }
    if (_config.contentViewCornerRadius < 0) {
        _config.contentViewCornerRadius = 10;
    }
    if (_config.buttonHeight < 0) {
        _config.buttonHeight = 40;
    }
    
    // 黑底
    UIView *blackView = [[UIView alloc] init];
    //blackView.backgroundColor = [UIColor colorNamed:@"color_1"]; // Test
    blackView.backgroundColor = [UIColor blackColor];
    blackView.frame = frame;
    blackView.alpha = _config.blackViewAlpha;
    blackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:blackView];
    
    //
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor colorNamed:@"color_4"]; // Test

    contentView.layer.cornerRadius = _config.contentViewCornerRadius;
    [self addSubview:contentView];
    _contentView = contentView;
    
    UIView *titleView = [[UIView alloc] init];   _titleView = titleView;
    UIView *middleView = [[UIView alloc] init];  _middleView = middleView;
    UIView *bottomView = [[UIView alloc] init];  _bottomView = bottomView;
    
    CGFloat X = 0, Y = 0, W = 0, H = 0, contentViewH = 0;
    CGRect sframe;
    
    // 标题
    if (_config.title.text.length > 0) {
        
        X = _config.title.leftPadding;
        Y = _config.title.topPadding;
        W = _config.contentViewWidth - X - _config.title.rightPadding;
        
        UILabel *titleLable = [self xx_setup_attributed_label:_config.title.text
                                                        color:_config.title.color
                                                         font:_config.title.font
                                                        width:W
                                                    lineSpace:_config.title.lineSpace];
        sframe = titleLable.frame;
        sframe.origin.x = X;
        sframe.origin.y = Y;
        
        titleLable.frame = sframe;
        titleLable.numberOfLines = _config.title.autoHeight ? 0 : 1;
        _titleLabel = titleLable;
        
        titleView.frame = CGRectMake(0, 0, _config.contentViewWidth, CGRectGetMaxY(titleLable.frame) + _config.title.bottomPadding);
        
        [titleView addSubview:titleLable];
        [contentView addSubview:titleView];
        
        contentViewH = CGRectGetMaxY(titleView.frame);
    }
    
    // 内容
    if (_config.content.text.length > 0) {
        
        //分割线
        if (_config.title.text.length > 0 && _config.titleBottomLineHidden == NO) {
            W = _config.contentViewWidth, H = 1.0/[UIScreen mainScreen].scale;
            sframe = CGRectMake(0,0,W,H);
            
            UIView *line = [self xx_setup_line:sframe];
            [middleView addSubview:line];
            _titleBottomLine = line;
        }
        
        X = _config.content.leftPadding;
        Y = _config.content.topPadding;
        W = _config.contentViewWidth - X - _config.content.rightPadding;
        
        UILabel *contentLabel = [self xx_setup_attributed_label:_config.content.text
                                                          color:_config.content.color
                                                           font:_config.content.font
                                                          width:W
                                                      lineSpace:_config.content.lineSpace];
        sframe = contentLabel.frame;
        sframe.origin.x = X;
        sframe.origin.y = Y;
        
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.frame = sframe;
        scrollView.backgroundColor = [UIColor colorNamed:@"color_2"]; // Test
        scrollView.contentSize = CGSizeMake(0, CGRectGetHeight(sframe));
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.pagingEnabled = NO;
        
        sframe.origin.x = 0;
        sframe.origin.y = 0;
        contentLabel.frame = sframe;
        contentLabel.numberOfLines = _config.content.autoHeight ? 0 : 1;
        _contentLabel = contentLabel;
        
        CGFloat maxY = CGRectGetMaxY(scrollView.frame) + _config.content.bottomPadding;
        if (_config.content.maxHeight > 0 && CGRectGetHeight(sframe) > _config.content.maxHeight) {
            
            //
            scrollView.frame = CGRectMake(X, Y, CGRectGetWidth(sframe), _config.content.maxHeight);
            
            //
            maxY = CGRectGetMaxY(scrollView.frame) + _config.content.bottomPadding;
        }
        
        [scrollView addSubview:contentLabel];
        [middleView addSubview:scrollView];
        
        middleView.frame = CGRectMake(0, contentViewH, _config.contentViewWidth, maxY);
        [contentView addSubview:middleView];
        
        contentViewH = CGRectGetMaxY(middleView.frame);
    }
    
    CGFloat buttonH = _config.buttonHeight;
    //按钮
    if (_config.buttons.count == 2) {
        
        // 分割线 横
        if (_config.title.text.length > 0 || _config.content.text.length > 0) {
            W = _config.contentViewWidth, H = 1.0/[UIScreen mainScreen].scale;
            sframe = CGRectMake(0,0,W,H);
            
            UIView *line = [self xx_setup_line:sframe];
            [bottomView addSubview:line];
        }
        
        // 分割线 竖
        X = _config.contentViewWidth*0.5, W = 1.0/[UIScreen mainScreen].scale, H = buttonH;
        sframe = CGRectMake(X,0,W,H);
        UIView *line = [self xx_setup_line:sframe];
        [bottomView addSubview:line];
        
        //按钮
        X = 0, W = _config.contentViewWidth*0.5;
        
        for (int i = 0; i < _config.buttons.count; ++i) {
            sframe = CGRectMake(X,0,W,H);
            JHUIAlertButtonConfig *btnConfig = _config.buttons[i];
            [self xx_setup_button:sframe title:btnConfig.title color:btnConfig.color font:btnConfig.font image:btnConfig.image superview:bottomView tag:i];
            X += W;
        }
        
        bottomView.frame = CGRectMake(0, contentViewH, _config.contentViewWidth, H);
        [contentView addSubview:bottomView];
        
        contentViewH = CGRectGetMaxY(bottomView.frame);
        
    }else if (_config.buttons.count > 0){
        Y = 0, W = _config.contentViewWidth, H = buttonH;
        for (int i = 0; i < _config.buttons.count; ++i) {
            sframe = CGRectMake(0,Y,W,H);
            JHUIAlertButtonConfig *btnConfig = _config.buttons[i];
            UIButton *button = [self xx_setup_button:sframe title:btnConfig.title color:btnConfig.color font:btnConfig.font image:btnConfig.image superview:bottomView tag:i];
            
            // space
            if (btnConfig.imageTitleSpace > 0) {
                [button setImageEdgeInsets:UIEdgeInsetsMake(0,0,0,btnConfig.imageTitleSpace)];
                [button setTitleEdgeInsets:UIEdgeInsetsMake(0,btnConfig.imageTitleSpace,0,0)];
            }
            
            //分割线
            if (i == 0 && _config.title.text.length == 0 && _config.content.text.length == 0){
                //no line
            }else{
                H = 0.5;
                sframe = CGRectMake(0,Y,W,H);
                UIView *line = [self xx_setup_line:sframe];
                [bottomView addSubview:line];
            }
            H = buttonH;
            Y += H;
        }
        
        bottomView.frame = CGRectMake(0, contentViewH, _config.contentViewWidth, _config.buttons.count*H);
        [contentView addSubview:bottomView];
        
        contentViewH = CGRectGetMaxY(bottomView.frame);
    }
    
    if (_config.dismissWhenTapOut) {
        [blackView addGestureRecognizer:({
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(xx_tap)];
        })];
    }
    
    // 完全自定义时
    if (_config.contentViewHeight > 0) {
        if (_config.title.text.length == 0 &&
            _config.content.text.length == 0 &&
            _config.buttons.count == 0) {
            contentViewH = _config.contentViewHeight;
        }
    }
    
    _contentViewHeight = contentViewH;
    
    if (_contentViewHeight > [UIScreen mainScreen].bounds.size.height - 100) {
        _contentViewHeight = [UIScreen mainScreen].bounds.size.height - 100;
        [self setupMiddleViewHeight:_contentViewHeight];
    }else{
        contentView.frame = CGRectMake(0,0,_config.contentViewWidth,_contentViewHeight);
    }
}

- (UILabel *)xx_setup_attributed_label:(NSString *)text
                                 color:(UIColor *)color
                                  font:(UIFont *)font
                                 width:(CGFloat)width
                             lineSpace:(CGFloat)lineSpace
{
    // set line space
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpace];
    paragraphStyle.alignment = NSTextAlignmentCenter; // 居中
    if ([text containsString:@"\n"]) {
        paragraphStyle.alignment = NSTextAlignmentLeft; // 居左
    }
    [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    [attStr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [text length])];
    [attStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [text length])];
    
    // calculate size
    CGSize size = CGSizeMake(width, MAXFLOAT);
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSParagraphStyleAttributeName:paragraphStyle};
    size = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    
    // label
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, width, size.height);
    label.attributedText = attStr;
    return label;
}

- (UIView *)xx_setup_line:(CGRect)frame{
    UIView *line = [[UIView alloc] init];
    line.frame = frame;
    //line.backgroundColor = [UIColor colorWithRed:0.82 green:0.82 blue:0.82 alpha:1];
    
    line.backgroundColor = [UIColor colorNamed:@"color_3"];// Test
    return line;
}

- (UIButton *)xx_setup_button:(CGRect)frame
                        title:(NSString *)title
                        color:(UIColor *)color
                         font:(UIFont *)font
                        image:(UIImage *)image
                    superview:(UIView *)view
                          tag:(NSInteger)tag
{
    UIButton *button = [UIButton buttonWithType:1];
    if (image) {
        button = [UIButton buttonWithType:0];
    }
    button.tag = tag;
    button.frame = frame;
    button.titleLabel.font = font==nil?[UIFont systemFontOfSize:18]:font;
    [button setTitle:title==nil?[NSString stringWithFormat:@"按钮%@",@(tag)]:title forState:0];
    [button setTitleColor:color forState:0];
    [button setImage:image forState:0];
    [button addTarget:self action:@selector(xx_click:) forControlEvents:1<<6];
    [view addSubview:button];
    return button;
}

- (void)xx_click:(UIButton *)button
{
    JHUIAlertButtonConfig *btnConfig = _config.buttons[button.tag];
    if (btnConfig.block) {
        btnConfig.block();
    }
    
    [self dismiss];
}

- (void)xx_tap
{
    if (_config.dismissWhenTapOut) {
        
        if (_tapOutDismissBlock) {
            _tapOutDismissBlock();
        }
        
        [self dismiss];
    }
}

- (void)willMoveToSuperview:(nullable UIView *)newSuperview{
    if (newSuperview) {
        if (_config.showAnimation) {
            self.transform = CGAffineTransformMakeScale(1.2, 1.2);
            self.alpha = 0;
            [UIView animateWithDuration:_config.showAnimationDuration animations:^{
                self.transform = CGAffineTransformIdentity;
                self.alpha = 1;
            }];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat W = CGRectGetWidth(self.frame);
    CGFloat H = CGRectGetHeight(self.frame);
    CGFloat newH = 0;
    
    if (W > H) {
        if (_rotation == 1) {
            return;
        }
        _rotation = 1;
        
        if (CGRectGetHeight(_contentView.frame) > H - 100) {
            newH = H - 100;
            [self setupMiddleViewHeight:newH];
        }
    }else{
        
        // the first time
        if (_rotation == 0) {
            _contentView.center = self.center;
            return;
        }
        
        if (_rotation == 2) {
            return;
        }
        _rotation = 2;
        
        newH = _contentViewHeight;
        [self setupMiddleViewHeight:newH];
    }
    
    _contentView.center = self.center;
}

- (void)setupMiddleViewHeight:(CGFloat)newH
{
    CGRect frame = _middleView.frame;
    frame.size.height = newH - CGRectGetHeight(_titleView.frame) - CGRectGetHeight(_bottomView.frame);
    _middleView.frame = frame;
    
    for (UIView *view in _middleView.subviews) {
        if (CGRectGetHeight(view.frame) < 1.0) {
            continue;
        }
        
        frame = view.frame;
        frame.size.height = CGRectGetHeight(_middleView.frame) - _config.content.topPadding - _config.content.bottomPadding;
        view.frame = frame;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            break;
        }
    }
        
    frame = _contentView.frame;
    frame.size.height = newH;
    _contentView.frame = frame;
    
    frame = _bottomView.frame;
    frame.origin.y = newH - CGRectGetHeight(frame);
    _bottomView.frame = frame;
}

- (void)addCustomView:(JHUIAlertViewAddCustomViewBlock)block{
    if (block) {
        CGRect frame = [_contentLabel.superview convertRect:_contentLabel.frame toView:_contentView];
        block(self, _contentView.frame, _titleLabel.frame, frame);
    }
}

- (void)showInView:(UIView *)view{
    [view addSubview:self];
}

- (void)dismiss{
    if (_config.showAnimation) {
        [UIView animateWithDuration:_config.showAnimationDuration animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }else{
        [self removeFromSuperview];
    }
}

@end



@implementation JHUIAlertConfig

- (instancetype)init{
    self = [super init];
    if (self) {
        
        _title = [[JHUIAlertTextConfig alloc] init];
        _title.text = @"";
        _title.topPadding = 10;
        _title.leftPadding = 10;
        _title.bottomPadding = 10;
        _title.rightPadding = 10;
        _title.autoHeight = YES;
        
        _content = [[JHUIAlertTextConfig alloc] init];
        _content.text = @"";
        _content.font = [UIFont systemFontOfSize:16];
        _content.topPadding = 15;
        _content.leftPadding = 20;
        _content.bottomPadding = 15;
        _content.rightPadding = 20;
        _content.autoHeight = YES;
        _content.lineSpace = 4;
        
        CGSize size = [UIScreen mainScreen].bounds.size;
        
        _titleBottomLineHidden = NO;
        _blackViewAlpha = 0.5;
        _showAnimation = YES;
        _showAnimationDuration = 0.25;
        _contentViewWidth = size.width - 100;
        _contentViewCornerRadius = 10;
        _dismissWhenTapOut = YES;
        _buttonHeight = 40;
    }
    return self;
}

@end


@implementation JHUIAlertTextConfig

- (instancetype)init{
    self = [super init];
    if (self) {
        _color = [UIColor blackColor];
        _font = [UIFont systemFontOfSize:18];
    }
    return self;
}

@end

@implementation JHUIAlertButtonConfig

+ (JHUIAlertButtonConfig *)configWithTitle:(NSString *)title color:(UIColor *)color font:(UIFont *)font image:(UIImage *)image handle:(dispatch_block_t)block{
    JHUIAlertButtonConfig *btnConfig = [[JHUIAlertButtonConfig alloc] init];
    btnConfig.title = title;
    btnConfig.color = color;
    btnConfig.font = font;
    btnConfig.image = image;
    btnConfig.block = block;
    return btnConfig;
}

@end
