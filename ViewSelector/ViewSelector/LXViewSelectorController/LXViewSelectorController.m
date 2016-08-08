//
//  LXViewSelectorController.m
//  ViewSelector
//
//  Created by XiaoleiLi on 16/8/8.
//  Copyright © 2016年 leehyoley. All rights reserved.
//

#import "LXViewSelectorController.h"
#define LXScreenWidth [[UIScreen mainScreen] bounds].size.width
@interface LXViewSelectorController ()
@property (nonatomic,strong)NSArray<UIViewController*> *controllers;//子控制器
@property (nonatomic,strong)NSArray<NSString*> *titles;//标题
@property (nonatomic,strong)UIView *selectorView;//顶部带选择标题容器
@property (nonatomic,strong)UIView *showView;//子控制器内容显示容器

@property (nonatomic,strong)NSArray<UIButton*> *titleButtons;//标题按钮
@property (nonatomic,strong)UIView *tipView;//位置提示条

@property (strong,nonatomic) NSArray *originArray;
@end

@implementation LXViewSelectorController

-(instancetype)initWithControllers:(NSArray<UIViewController*>*)controllers titles:(NSArray<NSString*>*)titles{
    if (self = [super init]) {
        self.controllers = controllers;
        self.titles = titles;
        //默认
        self.fontSize = 14;
        self.tipSize = CGSizeMake(40, 2);
        self.normalColor = [UIColor blackColor];
        self.selectedColor = [UIColor redColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];
    
    self.selectorView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, LXScreenWidth,45)];
    self.showView = [[UIView alloc] initWithFrame:CGRectMake(0, self.selectorView.frame.size.height+64, LXScreenWidth, self.view.bounds.size.height - self.selectorView.frame.size.height - 64)];
    
    NSMutableArray<UIButton*> *buttons = [NSMutableArray array];
    for (int i=0; i<self.controllers.count; i++) {
        UIViewController *vc = self.controllers[i];
        
        vc.view.frame = CGRectMake(i*self.showView.bounds.size.width, 0, self.showView.bounds.size.width, self.showView.bounds.size.height);
        [self.showView addSubview:vc.view];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i*(self.selectorView.bounds.size.width/self.controllers.count), 0, self.selectorView.bounds.size.width/self.controllers.count, 44)];
        button.tag = i;
        [button.titleLabel setFont:[UIFont systemFontOfSize:self.fontSize]];
        [button setTitle:self.titles[i] forState:UIControlStateNormal];
        [button setTitleColor:i==0?self.selectedColor:self.normalColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didClickItem:) forControlEvents:UIControlEventTouchUpInside];
        [buttons addObject:button];
        [self.selectorView addSubview:button];
    }
    self.titleButtons = [NSArray arrayWithArray:buttons];
    self.tipView = [[UIView alloc] initWithFrame:CGRectMake(0, self.selectorView.bounds.size.height-2, 40, 2)];
    self.tipView.center = CGPointMake(self.titleButtons[0].center.x, self.tipView.center.y);
    self.tipView.backgroundColor = [UIColor redColor];
    [self.selectorView addSubview:self.tipView];
    [self.view addSubview:self.selectorView];
    [self.view addSubview:self.showView];
    
    
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint point = [sender translationInView:self.showView];
    CGPoint poi = [sender velocityInView:self.showView];
    CGFloat x = self.showView.bounds.origin.x;
    if (fabs(point.x)>fabs(point.y)) {
        x-=point.x;
        if (x>=0&&x<=self.showView.bounds.size.width*(self.controllers.count-1)) {
            [self setAnimationWithOrigin:x];
        }
    }
    
    if (sender.state==UIGestureRecognizerStateEnded) {
        
        //poi为速度，point是位移
        //位移超过一半或者滑动结束时速度大于300就翻页，否则还原
        if (poi.x>300) {
            
            int count = (int)x/(int)self.showView.bounds.size.width;
            if (count>0) {
                x = self.showView.bounds.size.width*count;
            }else{
                x = 0;
            }
        }else if(poi.x<-300){
            int count = (int)x/(int)self.showView.bounds.size.width;
            if (count<self.controllers.count-1) {
                x = self.showView.bounds.size.width*(count+1);
            }else{
                x = self.showView.bounds.size.width*(self.controllers.count-1);
            }
        }else{
            int count = (int)x/(int)self.showView.bounds.size.width;
            int deviation = (int)x%(int)self.showView.bounds.size.width;
            if (deviation<self.showView.bounds.size.width/2) {
                x = count*self.showView.bounds.size.width;
            }else if(count<self.controllers.count-1){
                x = count*self.showView.bounds.size.width;
            }else{
                x = (self.controllers.count-1)*self.showView.bounds.size.width;
            }
            
        }
        [UIView animateWithDuration:0.3 animations:^{
            [self setAnimationWithOrigin:x];
        }];
    }
    
    
    [sender setTranslation:CGPointMake(0, 0) inView:self.showView];
}


-(void)didClickItem:(UIButton*)sender{
    [UIView animateWithDuration:0.3 animations:^{
        [self setAnimationWithOrigin:self.showView.bounds.size.width*sender.tag];
    }];
}
//根据bound偏移量，调整位置
-(void)setAnimationWithOrigin:(CGFloat)x{
    self.showView.bounds=CGRectMake(x, self.showView.bounds.origin.y,self.showView.bounds.size.width, self.showView.bounds.size.height);
    CGFloat tipX = self.selectorView.bounds.size.width/(self.controllers.count*2)+(x/(self.selectorView.bounds.size.width*(self.controllers.count-1)))*self.selectorView.bounds.size.width/(self.controllers.count)*(self.controllers.count-1);
    self.tipView.center=CGPointMake(tipX, self.tipView.center.y);
    [self.originArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ((int)tipX==[obj intValue]) {
            [self selectTitleAt:idx];
        }
    }];
}
-(void)selectTitleAt:(NSInteger)index{
    for (int i =0; i<self.titleButtons.count; i++) {
        UIButton *button = self.titleButtons[i];
        [button setTitleColor:i==index?self.selectedColor:self.normalColor forState:UIControlStateNormal];
    }
}

-(NSArray *)originArray{
    if (!_originArray) {
        
        NSMutableArray *tempArr = [NSMutableArray array];
        
        for (int i=0; i<self.controllers.count; i++) {
            [tempArr addObject:@(self.selectorView.bounds.size.width/(self.controllers.count*2)+self.selectorView.bounds.size.width*i/self.controllers.count)];
        }
        _originArray = [NSArray arrayWithArray:tempArr];
    }
    return _originArray;
}

@end
