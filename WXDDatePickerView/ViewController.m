//
//  ViewController.m
//  WXDDatePickerView
//
//  Created by Wan on 17/5/11.
//  Copyright © 2017年 zonsim. All rights reserved.
//

#import "ViewController.h"
#import "WXDDatePickerView.h"

@interface ViewController ()
{
    UIButton *_selectBtn;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectBtn.frame = CGRectMake((self.view.frame.size.width - 250) / 2, 200, 250, 50);
    _selectBtn.layer.cornerRadius = 5;
    _selectBtn.backgroundColor = [UIColor blueColor];
    [_selectBtn setTitle:@"选择时间" forState:UIControlStateNormal];
    [self.view addSubview:_selectBtn];
    [_selectBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)selectAction:(UIButton *)btn {
    
    WXDDatePickerView *dateView=[[WXDDatePickerView alloc] initWithFrame:[UIScreen mainScreen].bounds title:@"选择考试日期"];
    dateView.isAllowSelectPastDate = NO;
    dateView.dateStringBlock = ^(NSString *dateString){
        NSLog(@"%@",dateString);
        [_selectBtn setTitle:dateString forState:UIControlStateNormal];
    };
    [self.view addSubview:dateView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
