//
//  ViewController.m
//  GBChartLineView
//
//  Created by 印聪 on 2018/3/6.
//  Copyright © 2018年 tima. All rights reserved.
//

#import "ViewController.h"

#import "GBChartsLineView.h"

@interface ViewController ()<GBChartsLineViewDataSource , GBChartsLineViewDelegate>

@property (nonatomic , strong)GBChartsLineView *lineView;

@property (nonatomic , strong)NSArray <NSNumber *>*datasArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:238/255.0 alpha:1.0];
    
    [self.view addSubview:self.lineView];
        
    [self loadData];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.lineView.frame = CGRectMake(10, 40, self.view.bounds.size.width - 20, 200);
}


#pragma mark -- http request
- (void)loadData{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.datasArray = @[@(-5),@(-4),@(-1),@(4),@(8),@(9),@(20)];
        [self.lineView reloadData];
    });
    
}


#pragma mark -- GBChartsLineViewDataSource
- (NSArray <NSNumber *> *)datasForChartLineView:(GBChartsLineView *)chartLineView{
    return self.datasArray;
}


#pragma mark -- GBChartsLineViewDelegate
- (BOOL)showPointInChartLineView:(GBChartsLineView *)chartLineView{
    return YES;
}

#pragma mark -- getters and setters
- (GBChartsLineView *)lineView{
    if (_lineView == nil) {
        _lineView = [[GBChartsLineView alloc] init];
        _lineView.backgroundColor = [UIColor whiteColor];
        _lineView.dataSource = self;
        _lineView.delegate = self;
    }
    return _lineView;
}

@end
