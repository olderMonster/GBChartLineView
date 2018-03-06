//
//  GBChartsView.h
//  GoodBills
//
//  Created by 印聪 on 2018/3/1.
//  Copyright © 2018年 tima. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GBChartsLineView;


@protocol GBChartsLineViewDataSource<NSObject>

@required
- (NSArray <NSNumber *> *)datasForChartLineView:(GBChartsLineView *)chartLineView;

@optional
- (NSArray <NSString *> *)datasForXAxisInChartLineView:(GBChartsLineView *)chartLineView;
//X轴单位。当设置单位时，需先实现showXAxis方法
- (NSString *)unitForXAxis:(GBChartsLineView *)chartLineView;
//Y轴单位。当设置单位时，需先实现showYAxis方法
- (NSString *)unitForYAxis:(GBChartsLineView *)chartLineView;

@end

@protocol GBChartsLineViewDelegate<NSObject>

@required


@optional

/**
 是否显示数据点，默认不显示。当设置该属性之后sizeOfDataPoint失效
 
 @param chartLineView 视图
 @return 是否显示
 */
- (BOOL)showPointInChartLineView:(GBChartsLineView *)chartLineView;


/**
 是否显示X轴，默认不显示。当不显示的时候unitForXAxis方法无效

 @param chartLineView 视图
 @return 是否显示
 */
- (BOOL)showXAxis:(GBChartsLineView *)chartLineView;

/**
 是否显示Y轴，默认不显示。当不显示的时候unitForYAxis无效

 @param chartLineView 视图
 @return 是否显示
 */
- (BOOL)showYAxis:(GBChartsLineView *)chartLineView;


/**
 每个数据点的大小

 @param chartLineView 视图
 @return 点的大小
 */
- (CGSize)sizeOfDataPoint:(GBChartsLineView *)chartLineView;


/**
 每页显示的点的个数，默认是12个，最多显示31个(考虑以每月的天数作为单位)。当数据量比较大的情况下，一页不能显示所有的数据，因此分页显示

 @param chartLineView 视图
 @return 点的个数
 */
- (NSInteger)numberOfPointShowingInChartLineView:(GBChartsLineView *)chartLineView;


/**
 边距

 @param chartLineView 视图
 @return 边距
 */
- (UIEdgeInsets)edgeInsetsOfChartLineView:(GBChartsLineView *)chartLineView;



@end

@interface GBChartsLineView : UIView

@property (nonatomic , weak)id<GBChartsLineViewDataSource>dataSource;
@property (nonatomic , weak)id<GBChartsLineViewDelegate>delegate;

- (void)reloadData;

@end
