//
//  WXDDatePickerView.h
//  WXDDataPickerView
//
//  Created by Wan on 17/5/10.
//  Copyright © 2017年 zonsim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXDDatePickerView : UIView

/**
 初始化DatePickerView
 @param frame Frame
 @param title 标题
 */
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;

/**
 回调选中日期
 */
@property (nonatomic, copy) void (^dateStringBlock)(NSString *dateString);

/**
 是否允许选中当前时间之前的日期 , default is YES
 */
@property (nonatomic, assign) BOOL isAllowSelectPastDate;

@end

@interface UIView (DateExtesion)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;

@end
