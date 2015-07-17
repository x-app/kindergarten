//
//  AppDelegate.h
//  kindergarten
//
//  Created by slice on 15-7-1.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYBlurIntroductionView.h"
#import "WebViewController.h"
#import "KGUser.h"
#import "KGVarible.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, MYIntroductionDelegate>

@property (strong, nonatomic)WebViewController *webVC;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) KGUser *user;

@property (strong, nonatomic) KGVarible *varible;

@end

