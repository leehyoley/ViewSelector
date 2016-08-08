//
//  ViewController.m
//  ViewSelector
//
//  Created by XiaoleiLi on 16/8/8.
//  Copyright © 2016年 leehyoley. All rights reserved.
//

#import "ViewController.h"
#import "LXViewSelectorController.h"
#define RandomColor [UIColor colorWithRed:(random()%255)/255.0 green:(random()%255)/255.0 blue:(random()%255)/255.0 alpha:1]
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)click:(id)sender {
    
    
    //使用例子
    //准备要添加的控制器和标题数组
    NSMutableArray *vcArr = [NSMutableArray array];
    NSMutableArray *titleArr = [NSMutableArray array];
    for (int i =0; i<4; i++) {
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = RandomColor;
        [vcArr addObject:vc];
        [titleArr addObject:[NSString stringWithFormat:@"条目%d",i+1]];
    }
    
    //初始化并push
    LXViewSelectorController *vc = [[LXViewSelectorController alloc] initWithControllers:vcArr titles:titleArr];
    vc.title = @"视图选择器";
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
