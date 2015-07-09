//
//  AppDelegate.h
//  kindergarten
//
//  Created by slice on 15-7-1.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYBlurIntroductionView.h"
#import "KGUser.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, MYIntroductionDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) KGUser *user;

@end

