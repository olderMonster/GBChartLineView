//
//  GBChartsView.m
//  GoodBills
//
//  Created by 印聪 on 2018/3/1.
//  Copyright © 2018年 tima. All rights reserved.
//

#import "GBChartsLineView.h"

@interface GBChartsLineView()

@property (nonatomic , strong)UIScrollView *pointScrollView;
@property (nonatomic , strong)CAShapeLayer *lineShapeLayer;
@property (nonatomic , strong)UILabel *noContentLabel; //没有数据的时候显示
@property (nonatomic , strong)UILabel *XAxisUnitLabel; //X轴单位
@property (nonatomic , strong)UILabel *YAxisUnitLabel; //Y轴单位

@property (nonatomic , assign)CGSize pointSize; //点的尺寸
@property (nonatomic , assign)NSInteger maxPointNum; //每页的最大数量
@property (nonatomic , assign)UIEdgeInsets edgeInsets; //边距
@property (nonatomic , assign)BOOL showPoint; //是否显示数据点
@property (nonatomic , assign)CGFloat maxDataY;     //最大数值的点Y轴位置
@property (nonatomic , assign)CGFloat averageDataY; //当有数值小于0那么就是0的位置，否则就是最大最小平均值位置
@property (nonatomic , assign)CGFloat minDataY;     //最小数值的点Y轴位置
@property (nonatomic , assign)BOOL showXAxis; //是否显示X轴
@property (nonatomic , assign)BOOL showYAxis; //是否显示Y轴

@property (nonatomic , strong)NSArray <NSNumber *>*datasArray;   //存储点数据的数组
@property (nonatomic , strong)NSArray <NSValue *>*pointsArray;   //存储点的数组
@property (nonatomic , strong)NSArray <UIView *>*pointViewArray; //存储点视图的数组
@property (nonatomic , strong)NSArray <NSString *>*XAxisDatasArray; //存储x左边数据的数组
@property (nonatomic , strong)NSArray <UILabel *>*XAxisLabelArray; //存储x坐标label的数组
@property (nonatomic , strong)NSArray <UILabel *>*YAxisLabelArray; //存储y坐标label的数组

@property (nonatomic , assign)CGFloat maxPoint; //最大的数据值
@property (nonatomic , assign)CGFloat minPoint; //最小的数据值

@end

@implementation GBChartsLineView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.pointSize = CGSizeMake(10, 10);
        self.maxPointNum = 12;
        self.edgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        self.showPoint = NO;
        
        
        [self addSubview:self.pointScrollView];
        [self addSubview:self.noContentLabel];
        [self addSubview:self.XAxisUnitLabel];
        [self addSubview:self.YAxisUnitLabel];
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.pointScrollView.frame = self.bounds;
    self.noContentLabel.frame = self.bounds;
    
    if (self.XAxisUnitLabel.text != nil && self.showXAxis) {
        CGSize size = [self.XAxisUnitLabel.text sizeWithAttributes:@{NSFontAttributeName:self.XAxisUnitLabel.font}];
        self.XAxisUnitLabel.frame = CGRectMake(self.bounds.size.width - 5 - size.width, self.bounds.size.height - 3 - size.height, size.width, size.height);
    }
    
    if (self.YAxisUnitLabel.text != nil && self.showYAxis) {
        CGSize size = [self.YAxisUnitLabel.text sizeWithAttributes:@{NSFontAttributeName:self.YAxisUnitLabel.font}];
        self.YAxisUnitLabel.frame = CGRectMake(5, 3, size.width, size.height);
    }
    
    
    
    if (self.pointViewArray) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(showPointInChartLineView:)]) {
            self.showPoint = [self.delegate showPointInChartLineView:self];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(sizeOfDataPoint:)]) {
            self.pointSize = [self.delegate sizeOfDataPoint:self];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfPointShowingInChartLineView:)]) {
            NSInteger pointNum = [self.delegate numberOfPointShowingInChartLineView:self];
            self.maxPointNum = pointNum <= 31?:31;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(edgeInsetsOfChartLineView:)]) {
            self.edgeInsets = [self.delegate edgeInsetsOfChartLineView:self];
        }
        
        
        NSInteger currentShowPoint = self.maxPointNum;
        if (self.datasArray.count < self.maxPointNum && self.datasArray.count > 1) {
            currentShowPoint = self.datasArray.count;
        }
        //计算两点之间X轴方向的距离
        CGFloat pointInnerSpace = (self.bounds.size.width - self.edgeInsets.left - self.edgeInsets.right - currentShowPoint * self.pointSize.width)/(currentShowPoint - 1);
        //如果点的个数小于等于5个，两点之间X轴方向的距离为固定值，同时折线图居中显示
        if (self.pointViewArray.count <= 5) {
            pointInnerSpace = 40;
        }
       
        //获取最大值与最小值之间的差值
        CGFloat differenceNum = self.maxPoint - self.minPoint;
        //计算当前有效的显示折线的区域
        CGFloat availableHeight = self.pointScrollView.bounds.size.height - self.edgeInsets.top - self.edgeInsets.bottom;
        NSMutableArray *tmpPointMArray = [[NSMutableArray alloc] init];
        UIBezierPath *path = [UIBezierPath bezierPath];
        for (NSInteger index = 0; index < self.pointViewArray.count; index++) {
            CGFloat pointNum = [self.datasArray[index] floatValue];
            
            CGFloat centerY = self.pointScrollView.bounds.size.height * 0.5;
            if (differenceNum > 0) {
                centerY = self.edgeInsets.top + (self.maxPoint - pointNum) / differenceNum * availableHeight;
            }
            CGFloat centerX = self.edgeInsets.left + self.pointSize.width * 0.5 + (pointInnerSpace + self.pointSize.width) * index;
            if (self.pointViewArray.count <= 5) {
                if (self.pointViewArray.count%2 == 1) {
                    //奇数个点
                    NSInteger cols = (self.pointViewArray.count - 1)/2;
                    CGFloat startPointX = (self.pointScrollView.bounds.size.width - self.edgeInsets.left - self.edgeInsets.right) * 0.5 - cols * pointInnerSpace;
                    centerX = startPointX + pointInnerSpace * index;
                }else{
                    //偶数个点
                    NSInteger cols = self.pointViewArray.count/2;
                    CGFloat startPointX = (self.pointScrollView.bounds.size.width - self.edgeInsets.left - self.edgeInsets.right) * 0.5 - (cols - 0.5) * pointInnerSpace;
                    centerX = startPointX + pointInnerSpace * index;
                }
            }
            
            
            
            UIView *pointView = self.pointViewArray[index];
            pointView.bounds = CGRectMake(0, 0, self.pointSize.width, self.pointSize.height);
            pointView.center = CGPointMake(centerX, centerY);
            pointView.hidden = !self.showPoint;
            pointView.layer.masksToBounds = YES;
            pointView.layer.cornerRadius = pointView.bounds.size.width * 0.5;
            [tmpPointMArray addObject:[NSValue valueWithCGPoint:pointView.center]];
            
            if (index == 0) {
                [path moveToPoint:pointView.center];
            }else{
                [path addLineToPoint:pointView.center];
            }
            
            if (pointNum == self.maxPoint) {
                self.maxDataY = pointView.center.y;
            }else if (pointNum == self.minPoint){
                self.minDataY = pointView.center.y;
            }
            if (self.minPoint < 0 && self.maxPoint > 0) {
                CGFloat zeroPointY = self.edgeInsets.top + self.maxPoint / differenceNum * availableHeight;
                self.averageDataY = zeroPointY;
            }else{
                //同时大于0或者同时小于0
                self.averageDataY = (self.maxDataY + self.minDataY) * 0.5;
            }
            
            
            //显示X轴
            if (self.XAxisLabelArray.count > 0 && self.showXAxis) {
                
                UILabel *xLabel = self.XAxisLabelArray[index];
                CGSize size = [xLabel.text sizeWithAttributes:@{NSFontAttributeName:xLabel.font}];
                if (size.width > 40) {
                    size.width = 40;
                }
                xLabel.bounds = CGRectMake(0, 0, size.width, size.height);
                xLabel.center = CGPointMake(pointView.center.x, self.bounds.size.height - self.edgeInsets.bottom + self.edgeInsets.bottom * 0.5);
            }
            
            if (index == self.pointViewArray.count - 1) {
                if (pointView.center.x > self.pointScrollView.bounds.size.width - self.edgeInsets.right) {
                    self.pointScrollView.contentSize = CGSizeMake(pointView.center.x + self.edgeInsets.right, 0);
                }else{
                    self.pointScrollView.contentSize = CGSizeZero;
                }
            }
            
        }
        
        
        
        
        self.lineShapeLayer.path = path.CGPath;
        
        self.pointsArray = [[NSArray alloc] initWithArray:tmpPointMArray];
        
        //显示Y轴
        if (self.showYAxis) {
            for (NSInteger index = 0; index < self.YAxisLabelArray.count; index++) {
                
                CGFloat yLabelY = 0;
                if (index == 0) {
                    //max
                    yLabelY = self.maxDataY;
                }
                if (index == 1) {
                    //average
                    yLabelY = self.averageDataY;
                }
                if (index == 2){
                    //min
                    yLabelY = self.minDataY;
                }
                UILabel *yLabel = self.YAxisLabelArray[index];
                yLabel.bounds = CGRectMake(0, 0, self.edgeInsets.left, 20);
                yLabel.center = CGPointMake(self.edgeInsets.left * 0.5, yLabelY);
                
                if (self.maxDataY == self.minDataY || self.maxPoint == self.averageDataY || self.minDataY == self.averageDataY) {
                    break;
                }
            }
        }
        
        
    }
}

#pragma mark -- public method
- (void)reloadData{
    
    NSAssert(self.dataSource || [self.dataSource respondsToSelector:@selector(datasForChartLineView:)], @"请事先数据源代理方法");
    
    self.datasArray = [self.dataSource datasForChartLineView:self];
    self.noContentLabel.hidden = !(self.datasArray.count == 0);
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(datasForXAxisInChartLineView:)]) {
        self.XAxisDatasArray = [self.dataSource datasForXAxisInChartLineView:self];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(showXAxis:)]) {
        self.showXAxis = [self.delegate showXAxis:self];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(showYAxis:)]) {
        self.showYAxis = [self.delegate showYAxis:self];
    }
    
    if (self.datasArray && self.XAxisDatasArray && self.datasArray.count != self.XAxisDatasArray.count) {
        NSLog(@"数据不一致！");
        return;
    }
    
    NSInteger count = self.datasArray.count;
    
    for (UIView *view in self.pointViewArray) {
        [view removeFromSuperview];
    }
    for (UIView *view in self.XAxisLabelArray) {
        [view removeFromSuperview];
    }
    for (UIView *view in self.YAxisLabelArray) {
        [view removeFromSuperview];
    }
    
    self.pointViewArray = [[NSArray alloc] init];
    self.XAxisLabelArray = [[NSArray alloc] init];
    self.YAxisLabelArray = [[NSArray alloc] init];
    
    
    NSMutableArray *tmpPointMArray = [[NSMutableArray alloc] init];
    NSMutableArray *tmpXAxisLabelArray = [[NSMutableArray alloc] init];
    for (NSInteger index = 0; index < count; index++) {
        UIView *pointView = [[UIView alloc] init];
        pointView.backgroundColor = [UIColor colorWithRed:57/255.0 green:213/255.0 blue:153/255.0 alpha:1.0];
        pointView.tag = index;
        [self.pointScrollView addSubview:pointView];
        [tmpPointMArray addObject:pointView];
        
        //找到最大最小的数据点值
        CGFloat num = [self.datasArray[index] floatValue];
        if (num > self.maxPoint) {
            self.maxPoint = num;
        }
        if (num < self.minPoint) {
            self.minPoint = num;
        }
        
        
        if (self.XAxisDatasArray.count > 0) {
            UILabel *xLabel = [[UILabel alloc] init];
            xLabel.font = [UIFont systemFontOfSize:10];
            xLabel.textColor = [UIColor grayColor];
            xLabel.text = self.XAxisDatasArray[index];
            [self.pointScrollView addSubview:xLabel];
            [tmpXAxisLabelArray addObject:xLabel];
        }
        
    }
    
    
    NSMutableArray *tmpYAxisLabelArray = [[NSMutableArray alloc] init];
    if (count > 0) {
        for (NSInteger index = 0; index < 3; index++) {
            CGFloat balance = 0.00;
            if (index == 0) {
                balance = self.maxPoint;
            }
            if (index == 2){
                balance = self.minPoint;
            }
            
            NSString *text = [NSString stringWithFormat:@"%.2f",balance];
            if (balance >= 1000 || balance <= -1000) {
                text = [NSString stringWithFormat:@"%.2f万",balance/10000];
            }
            
            UILabel *yLabel = yLabel = [[UILabel alloc] init];
            yLabel.font = [UIFont systemFontOfSize:10];
            yLabel.textColor = [UIColor grayColor];
            yLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:yLabel];
            yLabel.text = text;
            [tmpYAxisLabelArray addObject:yLabel];
        }
    }
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(unitForXAxis:)]) {
        NSString *XUnit = [self.dataSource unitForXAxis:self];
        self.XAxisUnitLabel.text = [NSString stringWithFormat:@"/%@",XUnit];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(unitForYAxis:)]) {
        NSString *YUnit = [self.dataSource unitForYAxis:self];
        self.YAxisUnitLabel.text = [NSString stringWithFormat:@"/%@",YUnit];
    }
    
    
    self.pointViewArray = [[NSArray alloc] initWithArray:tmpPointMArray];
    self.XAxisLabelArray = [[NSArray alloc] initWithArray:tmpXAxisLabelArray];
    self.YAxisLabelArray = [[NSArray alloc] initWithArray:tmpYAxisLabelArray];
    
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

#pragma mark -- getters and setters
- (UIScrollView *)pointScrollView{
    if (_pointScrollView == nil) {
        _pointScrollView = [[UIScrollView alloc] init];
        _pointScrollView.showsVerticalScrollIndicator = NO;
        _pointScrollView.showsHorizontalScrollIndicator = NO;
        [_pointScrollView.layer addSublayer:self.lineShapeLayer];
    }
    return _pointScrollView;
}

- (CAShapeLayer *)lineShapeLayer{
    if (_lineShapeLayer == nil) {
        _lineShapeLayer = [CAShapeLayer layer];
        _lineShapeLayer.strokeColor = [UIColor colorWithRed:57/255.0 green:213/255.0 blue:153/255.0 alpha:1.0].CGColor;
        _lineShapeLayer.fillColor = [UIColor clearColor].CGColor;
        _lineShapeLayer.lineWidth = 5.0;
        _lineShapeLayer.lineCap = kCALineCapRound; //线条拐角
    }
    return _lineShapeLayer;
}

- (UILabel *)noContentLabel{
    if (_noContentLabel == nil) {
        _noContentLabel = [[UILabel alloc] init];
        _noContentLabel.text = @"暂无数据";
        _noContentLabel.textColor = [UIColor grayColor];
        _noContentLabel.textAlignment = NSTextAlignmentCenter;
        _noContentLabel.font = [UIFont systemFontOfSize:15];
        _noContentLabel.hidden = YES;
    }
    return _noContentLabel;
}

- (UILabel *)XAxisUnitLabel{
    if (_XAxisUnitLabel == nil) {
        _XAxisUnitLabel = [[UILabel alloc] init];
        _XAxisUnitLabel.textColor = [UIColor grayColor];
        _XAxisUnitLabel.font = [UIFont systemFontOfSize:10];
    }
    return _XAxisUnitLabel;
}

- (UILabel *)YAxisUnitLabel{
    if (_YAxisUnitLabel == nil) {
        _YAxisUnitLabel = [[UILabel alloc] init];
        _YAxisUnitLabel.textColor = [UIColor grayColor];
        _YAxisUnitLabel.font = [UIFont systemFontOfSize:10];
    }
    return _YAxisUnitLabel;
}

@end
