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

@property (strong, nonatomic) NSString *lastUID; //切换用户时，记录上一个用户的uid（用于deleteToken）

@property (strong, nonatomic) KGVarible *varible;

@property (strong, nonatomic) NSString* devicetoken;

@property (nonatomic) NSInteger appVersion; //0表示家长版  1表示教师版

@property (nonatomic) BOOL isLaunchedByNotification;

@property (strong, nonatomic)NSString *pushUrl;
@property (strong, nonatomic)NSString *pushFunc;
//@property (nonatomic)NSInteger myPushBadge;

@property (weak, nonatomic)UIViewController *curKGVC;

-(void)postToken;
-(void)deleteToken;
-(void)replaceToken:(void (^)())success
            failure:(void (^)())failure;
@end

