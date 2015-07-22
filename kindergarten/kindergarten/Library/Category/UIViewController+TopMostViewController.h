//
//  UIViewController+TopMostViewController.h
//  kindergarten
//
//  Created by wangbin on 15/7/21.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (TopMostViewController)

- (UIViewController *)topMostViewController;

@end

@interface UIApplication (TopMostViewController)

- (UIViewController *)topMostViewController;

@end