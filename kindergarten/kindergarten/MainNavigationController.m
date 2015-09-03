//
//  MainNavigationController.m
//  kindergarten
//
//  Created by ShiLiangdong on 15/8/7.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "MainNavigationController.h"

@interface MainNavigationController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

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

    __weak MainNavigationController *weakSelf = self;
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = weakSelf;
    }
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [gestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Hijack the push method to disable the gesture

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    [super pushViewController:viewController animated:animated];
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate
{
    // Enable the gesture again once the new controller is shown
    
//    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.interactivePopGestureRecognizer.enabled = YES;
//    }
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        // disable interactivePopGestureRecognizer in the rootViewController of navigationController
        if ([[self.viewControllers firstObject] isEqual:viewController]) {
            self.interactivePopGestureRecognizer.enabled = NO;
        } else {
            // enable interactivePopGestureRecognizer
            self.interactivePopGestureRecognizer.enabled = YES;
        }
    }
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
