//
//  WXDDatePickerView.m
//  WXDDataPickerView
//
//  Created by Wan on 17/5/10.
//  Copyright © 2017年 zonsim. All rights reserved.
//

#import "WXDDatePickerView.h"

#define DatePickerViewMargin self.width * .1
#ifndef RGBA
#define RGBA(r, g, b, a) ([UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:a])
#endif
#ifndef Iphone6p
// 屏幕5.5inch
#define Iphone6p ([UIScreen mainScreen].bounds.size.height == 736)
#endif
#ifndef FourInchPlus
// 屏幕4.7inch以上
#define FourInchPlus ([UIScreen mainScreen].bounds.size.height >= 667)
#endif
#ifndef FontSize
// 适配字体
#define FontSize(fontSize) FourInchPlus ? (Iphone6p ? [UIFont systemFontOfSize:fontSize + 2] : [UIFont systemFontOfSize:fontSize + 1]) : [UIFont systemFontOfSize:fontSize]
#endif
#define MAXYEAR 2050            // 年份最大
#define MINYEAR 1970            // 年份最小

@interface WXDDatePickerView () <UIPickerViewDelegate,UIPickerViewDataSource>
{
    UIView *_popView;                 // popView
    UIPickerView *_pickerView;        // pickerView
    NSMutableArray *_yearsArr;        // 年份数组
    NSMutableArray *_monthsArr;       // 月份份数组
    NSMutableArray *_daysArr;         // 日份数组
    
    NSString *selectYearStr;          // 选中的年份
    NSString *selectMonthStr;         // 选中的月份
    NSString *selectDayStr;           // 选中的日
}

@end

@implementation WXDDatePickerView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title
{
    if (self = [super initWithFrame:frame]) {
        
        [self initializeUIWithTitle:title];
        [self initializeDefaultDate];
    }
    return self;
}

// 创建UI
- (void)initializeUIWithTitle:(NSString *)title
{
    // 背景View
    UIButton *backgroundView = [UIButton buttonWithType:UIButtonTypeSystem];
    backgroundView.backgroundColor = RGBA(0, 0, 0, .3);
    backgroundView.frame = CGRectMake(0, 0, self.width, self.height);
    [self addSubview:backgroundView];
    
    // pickerView
    _popView = [[UIView alloc] init];
    CGFloat pickerViewW = self.width * .9;
    CGFloat pickerViewH = self.height * .5;
    _popView.size = CGSizeMake(pickerViewW, pickerViewH);
    _popView.center = self.center;
    _popView.backgroundColor = [UIColor whiteColor];
    _popView.layer.masksToBounds = YES;
    _popView.layer.cornerRadius = 8;
    [backgroundView addSubview:_popView];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _popView.width, _popView.height * .2)];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = FontSize(17);
    //    titleLabel.backgroundColor = [UIColor yellowColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [_popView addSubview:titleLabel];
    
    // 横线1
    UIView *horizonLine1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), self.width, 1)];
    horizonLine1.backgroundColor = RGBA(237, 237, 237, 1.0);
    [_popView addSubview:horizonLine1];
    
    // 年、月、日 文字
    NSArray *nameArr = @[@"年",@"月",@"日"];
    CGFloat labelW = (_popView.width - 2 * DatePickerViewMargin) / 3;
    CGFloat labelH = _popView.height * .15;
    CGFloat labelY = CGRectGetMaxY(horizonLine1.frame);
    for (int i = 0; i < 3; i ++) {
        CGFloat labelX = i * labelW + DatePickerViewMargin;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
        label.text = nameArr[i];
        label.textColor = RGBA(210, 55, 61, 1.0);
        label.font = FontSize(18);
        label.textAlignment = NSTextAlignmentCenter;
        [_popView addSubview:label];
    }
    
    // 横线2
    UIView *horizonLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, labelY + labelH, self.width, 1)];
    horizonLine2.backgroundColor = RGBA(237, 237, 237, 1.0);
    [_popView addSubview:horizonLine2];
    
    // pickerView
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.frame = CGRectMake(DatePickerViewMargin, CGRectGetMaxY(horizonLine2.frame), _popView.width - 2 * DatePickerViewMargin, _popView.height * .5);
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    _pickerView = pickerView;
    [_popView addSubview:pickerView];
    
    // 横线2
    UIView *horizonLine3 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(pickerView.frame), self.width, 1)];
    horizonLine3.backgroundColor = RGBA(237, 237, 237, 1.0);
    [_popView addSubview:horizonLine3];
    
    // 取消按钮
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTintColor:[UIColor grayColor]];
    cancelButton.titleLabel.font = FontSize(16);
    cancelButton.frame = CGRectMake(0, CGRectGetMaxY(horizonLine3.frame), _popView.width / 2, _popView.height - CGRectGetMaxY(horizonLine3.frame));
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_popView addSubview:cancelButton];
    
    
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [okButton setTitle:@"确定" forState:UIControlStateNormal];
    [okButton setTintColor:RGBA(210, 55, 61, 1.0)];
    okButton.titleLabel.font = FontSize(16);
    okButton.frame = CGRectMake(CGRectGetMaxX(cancelButton.frame), cancelButton.y, cancelButton.width, cancelButton.height);
    [okButton addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_popView addSubview:okButton];
    
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
    }];
}

// 设置默认日期
- (void)initializeDefaultDate
{
    // default is YES , 可选当前时间之前的日期
    self.isAllowSelectPastDate = YES;
    
    _yearsArr = [NSMutableArray new];
    _monthsArr = [NSMutableArray new];
    _daysArr = [NSMutableArray new];
    
    // 年
    for (int i = MINYEAR; i < MAXYEAR; i ++) {
        NSString *subYearStr = [NSString stringWithFormat:@"%zd",i];
        [_yearsArr addObject:subYearStr];
    }
    // 月
    for (int i = 1; i <= 12; i ++) {
        NSString *subMonthStr = [NSString stringWithFormat:@"%zd",i];
        [_monthsArr addObject:subMonthStr];
    }
    // 日
    NSDate *currentDate = [NSDate date];
    for (int i = 1; i <= [self totaldaysInThisMonth:currentDate]; i++) {
        NSString *subDayStr = [NSString stringWithFormat:@"%zd",i];
        [_daysArr addObject:subDayStr];
    }
    
    // 显示今天年月日
    [self pickerViewScrollToToday];
}

#pragma mark pickerViewScrollToToday
- (void)pickerViewScrollToToday
{
    NSDate *today = [NSDate date];
    // 年
    NSString *yearStr = [NSString stringWithFormat:@"%zd",[self year:today]];
    selectYearStr = yearStr;
    [_yearsArr enumerateObjectsUsingBlock:^(NSString *subYearStr, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([selectYearStr isEqualToString:subYearStr]) {
            [_pickerView selectRow:idx inComponent:0 animated:NO];
            *stop = YES;
        }
    }];
    // 月
    NSString *monthStr = [NSString stringWithFormat:@"%zd",[self month:today]];
    selectMonthStr = monthStr;
    [_monthsArr enumerateObjectsUsingBlock:^(NSString *subMonthStr, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([selectMonthStr isEqualToString:subMonthStr]) {
            [_pickerView selectRow:idx inComponent:1 animated:NO];
            *stop = YES;
        }
    }];
    // 日
    NSString *dayStr = [NSString stringWithFormat:@"%zd",[self day:today]];
    selectDayStr = dayStr;
    [_daysArr enumerateObjectsUsingBlock:^(NSString *subDayStr, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([selectDayStr isEqualToString:subDayStr]) {
            [_pickerView selectRow:idx inComponent:2 animated:NO];
            *stop = YES;
        }
    }];
}

#pragma mark cancelButtonClick
- (void)cancelButtonClick:(UIButton *)cancelBtn
{
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 0.0;
    }completion:^(BOOL finished) {
        if (finished){
            [self removeFromSuperview];
        }
    }];
}

#pragma mark okButtonClick
- (void)okButtonClick:(UIButton *)okButton
{
    if ([self isViewScrolling:_pickerView]) return;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 0.0;
    }completion:^(BOOL finished) {
        if (finished){
            [self removeFromSuperview];
            if (self.dateStringBlock) {
                NSString *selectDateStr = [NSString stringWithFormat:@"%@-%@-%@",selectYearStr,selectMonthStr,selectDayStr];
                self.dateStringBlock(selectDateStr);
            }
        }
    }];
}

#pragma mark 判断pickerView是否在滚动
- (BOOL)isViewScrolling:(UIView *)view
{
    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)view;
        if (scrollView.dragging || scrollView.decelerating) {
            return YES;
        }
    }
    for (UIView *theSubView in view.subviews) {
        if ([self isViewScrolling:theSubView]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *numberArr = @[@(_yearsArr.count),@(_monthsArr.count),@(_daysArr.count)];
    return [numberArr[component] integerValue];
}

#pragma mark UIPickerViewDelegate
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *stringArr = @[_yearsArr,_monthsArr,_daysArr];
    return stringArr[component][row];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *customLabel = (UILabel *)view;
    if (!customLabel) {
        customLabel = [[UILabel alloc] init];
        customLabel.textAlignment = NSTextAlignmentCenter;
        [customLabel setFont:FontSize(22)];
    }
    NSString *title;
    switch (component) {
        case 0:
            title = _yearsArr[row];
            break;
        case 1:
            title = _monthsArr[row];
            break;
        case 2:
            title = _daysArr[row];
            break;
        default:
            break;
    }
    customLabel.text = title;
    customLabel.textColor = [UIColor blackColor];
    
    return customLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            selectYearStr = _yearsArr[row];
            break;
        case 1:
            selectMonthStr = _monthsArr[row];
            break;
        case 2:
            selectDayStr = _daysArr[row];
            break;
        default:
            break;
    }
    if (component == 0 || component == 1) {
        NSString *dateStr = [NSString stringWithFormat:@"%@-%@",selectYearStr,selectMonthStr];
        NSDate *date = [self dateFromString:dateStr withDateFormat:@"yyyy-MM"];
        [_daysArr removeAllObjects];
        for (int i = 1; i <= [self totaldaysInThisMonth:date]; i ++) {
            NSString *subDayStr = [NSString stringWithFormat:@"%zd",i];
            [_daysArr addObject:subDayStr];
        }
        [_pickerView reloadAllComponents];
        // 处理每月最大日期
        if (selectDayStr.integerValue > _daysArr.count) {
            selectDayStr = [_daysArr lastObject];
        }
    }
    
    // 是否允许选当前时间之前的日期
    [self allowSelectPastDate];
}

- (void)allowSelectPastDate
{
    if (!self.isAllowSelectPastDate) { // 不能选当前时间之前的日期
        NSDate *currentDate = [NSDate date];
        NSString *otherDateStr = [NSString stringWithFormat:@"%@-%@-%@",selectYearStr,selectMonthStr,selectDayStr];
        NSDate *otherDate = [self dateFromString:otherDateStr withDateFormat:@"yyyy-MM-dd"];
        NSInteger result = [self comparedDate:currentDate withOtherDate:otherDate withDateFormat:@"yyyy-MM-dd"];
        if (result == 1) { // 选中日期在当前时间之前
            if (selectYearStr.integerValue < [self year:currentDate]) {
                selectYearStr = [NSString stringWithFormat:@"%zd",[self year:currentDate]];
                [_yearsArr enumerateObjectsUsingBlock:^(NSString *subYearStr, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([selectYearStr isEqualToString:subYearStr]) {
                        [_pickerView selectRow:idx inComponent:0 animated:YES];
                        *stop = YES;
                    }
                }];
            }
            if (selectMonthStr.integerValue < [self month:currentDate]) {
                selectMonthStr = [NSString stringWithFormat:@"%zd",[self month:currentDate]];
                [_monthsArr enumerateObjectsUsingBlock:^(NSString *subMonthStr, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([selectMonthStr isEqualToString:subMonthStr]) {
                        [_pickerView selectRow:idx inComponent:1 animated:YES];
                        *stop = YES;
                    }
                }];
            }
            if (selectDayStr.integerValue < [self day:currentDate]) {
                selectDayStr = [NSString stringWithFormat:@"%zd",[self day:currentDate]];
                [_daysArr enumerateObjectsUsingBlock:^(NSString *subDayStr, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([selectDayStr isEqualToString:subDayStr]) {
                        [_pickerView selectRow:idx inComponent:2 animated:YES];
                        *stop = YES;
                    }
                }];
            }
        }
    }
}

#pragma mark - date
// NSDate 转 NSString
- (NSString*)stringFromDate:(NSDate*)date withDateFormat:(NSString *)format
{
    //获取系统当前时间
    NSDate*currentDate = [NSDate date];
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    [dateFormatter setDateFormat:format];
    //NSDate转NSString
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    return currentDateString;
}

// NSString 转 NSDate
- (NSDate*)dateFromString:(NSString*)string withDateFormat:(NSString *)format
{
    //设置转换格式
    NSDateFormatter*formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    //NSString转NSDate
    NSDate *date = [formatter dateFromString:string];
    return date;
}

// 比较两个日期前后
- (NSInteger)comparedDate:(NSDate *)date withOtherDate:(NSDate *)otherDate withDateFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    NSString *otherDateStr = [dateFormatter stringFromDate:otherDate];
    NSDate *dateA = [dateFormatter dateFromString:dateStr];
    NSDate *dateB = [dateFormatter dateFromString:otherDateStr];
    NSComparisonResult result = [dateA compare:dateB];
    if (result == NSOrderedDescending) {
        return 1;   // otherDate are in the past
    }else if (result == NSOrderedAscending){
        return -1;  // otherDate are in the furture
    }
    // two dates are same
    return 0;
}

// 返回今天是星期几
- (NSInteger)weekday:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:date];
    return [components weekday];
}

// date是几号
- (NSInteger)day:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components day];
}

// 返回月份
- (NSInteger)month:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components month];
}

// 返回年
- (NSInteger)year:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components year];
}

// 这个月有几天
- (NSInteger)totaldaysInThisMonth:(NSDate *)date{
    NSRange totaldaysInMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return totaldaysInMonth.length;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@implementation UIView (DateExtesion)

- (void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)x{
    return self.frame.origin.x;
}

- (CGFloat)y{
    return self.frame.origin.y;
}

- (void)setCenterX:(CGFloat)centerX{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY{
    return self.center.y;
}

- (void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height{
    return self.frame.size.height;
}

- (CGFloat)width{
    return self.frame.size.width;
}

- (void)setSize:(CGSize)size{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size{
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin{
    return self.frame.origin;
}

@end

