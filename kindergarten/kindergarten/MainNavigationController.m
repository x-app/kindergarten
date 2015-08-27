//
//  MainNavigationController.m
//  kindergarten
//
//  Created by ShiLiangdong on 15/8/7.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "MainNavigationController.h"

@interface MainNavigationController ()

@end

@implementation MainNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(self.tabBarItem.tag == 1)
        self.tabBarItem.selectedImage=[UIImage imageNamed:@"baby_icon_selected-Small.png"];//选中图片
    else if(self.tabBarItem.tag == 2)
        self.tabBarItem.selectedImage=[UIImage imageNamed:@"class_icon_selected-Small.png"];//选中图片
    else if(self.tabBarItem.tag == 3)
        self.tabBarItem.selectedImage=[UIImage imageNamed:@"park_icon_selected-Small.png"];//选中图片
    else if(self.tabBarItem.tag == 4)
        self.tabBarItem.selectedImage=[UIImage imageNamed:@"my_icon_selected-Small.png"];//选中图片
    
    //tabicon selected color
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:0 green:211/255.0 blue:2/255.0 alpha:1];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
