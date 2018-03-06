# GBChartLineView

定义一个全局变量
```
@property (nonatomic , strong)GBChartsLineView *lineView;
```

实现getter方法
```
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
```

设置数据源，数据源中存放的是NSNumber类型的数据
```
#pragma mark -- GBChartsLineViewDataSource
- (NSArray <NSNumber *> *)datasForChartLineView:(GBChartsLineView *)chartLineView{
    return self.datasArray;
}
```
通过以上几行代码就可以绘制一个折线图了。还可以通过其他的代理方法来设置折线图的相关属性。

1.设置折线图是否显示数据点：
```
- (BOOL)showPointInChartLineView:(GBChartsLineView *)chartLineView
```

2.设置折线图显示X、Y轴
```
- (BOOL)showXAxis:(GBChartsLineView *)chartLineView
```
```
- (BOOL)showYAxis:(GBChartsLineView *)chartLineView
```

如果显示数轴，那么可以设置数轴的数据源:
```
- (NSString *)unitForXAxis:(GBChartsLineView *)chartLineView
```

3.以上只是部分属性设置，还有部分属性未展示，具体使用可以参考.h文件中的注释说明。
目前还没有添加点击显示等操作事件，后期会考虑添加一些其他的相关功能。

![](ttps://github.com/olderMonster/GBChartLineView/blob/master/ScreenShot/Simulator%20Screen%20Shot%20-%20iPhone%206s%20Plus%20-%202018-03-06%20at%2015.54.04.png)