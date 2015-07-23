//
//  AppDelegate.m
//  kindergarten
//
//  Created by slice on 15-7-1.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginProfileViewController.h"
#import "KGUtil.h"
//#import "MYBlurIntroductionView.h"

@interface AppDelegate ()

//app退出激活状态时的时间(按home键退出,下拉通知菜单, 上拉控制中心时触发)
@property (nonatomic, strong) NSDate *resignActiveTime;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.user = [[KGUser alloc] init];
    self.user.verified = NO;
    self.user.registered = NO;
    NSInteger visitTimes = 0;
    
    self.varible = [[KGVarible alloc] init];
    self.varible.server_index_url = @"http://app.nugget-nj.com/kindergarten_index";
    //self.varible.server_app_url = @"http://app.nugget-nj.com/nugget_app";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    visitTimes = [userDefaults integerForKey:@"visitTimes"];
    
//    for the first time test
    //visitTimes = 0;
    //
    self.resignActiveTime = nil;
    
    if (visitTimes == 0) {
        //create UI
        CGRect windowFrame = [[UIScreen mainScreen] bounds];
        UIWindow *theWindow = [[UIWindow alloc] initWithFrame:windowFrame];
        [self setWindow:theWindow];
        
        CGFloat frameWidth = windowFrame.size.width;
        CGFloat frameHeight = windowFrame.size.height;
        //新建欢迎界面的四个界面
        NSMutableArray *panels = [[NSMutableArray alloc] init];
        for (int i = 1; i <= 4; i++) {
            NSString *nibName = [NSString stringWithFormat:@"help_%d", i];
            NSLog(@"%@", nibName);
            MYIntroductionPanel *panel = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, frameWidth, frameHeight) nibNamed:nibName];
            [panels addObject:panel];
        }
        
        //Create the introduction view and set its delegate
        MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, frameHeight)];
        
        
        introductionView.delegate = self;
        [introductionView setBackgroundColor:[UIColor whiteColor]];

        //Build the introduction with desired panels
        [introductionView buildIntroductionWithPanels:panels];
        
        [[self window] addSubview:introductionView];
    } else {
        [self introduction:nil didFinishWithType:0];
    }
    
    NSDictionary *variDict = [userDefaults objectForKey:@"varible"];
    if (variDict != nil) {
        [self.varible fromDictionary:variDict];
    }
    visitTimes++;
    
    //存储时，除NSNumber类型使用对应的类型意外，其他的都是使用setObject:forKey:
    [userDefaults setInteger:visitTimes forKey:@"visitTimes"];
    
    //这里建议同步存储到磁盘中，但是不是必须的
    [userDefaults synchronize];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    self.resignActiveTime = [[NSDate alloc] init];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    UIWindow *window = [[application windows] objectAtIndex:0];
//    if ([window.rootViewController isKindOfClass:[UINavigationController class]]) {
//        UINavigationController *nav = (UINavigationController *)window.rootViewController;
//    }
    //NSString *clsName =  NSStringFromClass([window.rootViewController class]);
    //NSLog(@"become active: %@",clsName);
    //NSLog(@"become active: %@",[[window.rootViewController class] description]);
    self.user.verified = NO;
    NSLog(@"did become active in AppDelegate");
    NSDate *curTime = [[NSDate alloc] init];
    if (self.resignActiveTime == nil || [curTime timeIntervalSinceDate:self.resignActiveTime] > 10) {
        [KGUtil lockTopMostVC];
    }
    /*UIViewController *tmVC = [[UIApplication sharedApplication] topMostViewController];
    if (tmVC == nil) {
        NSLog(@"top most vc is nil");
    }
    if (!self.user.verified && !self.user.registering) {
        NSLog(@"用户尚未注册或者验证没过");
        [CLLockVC showVerifyLockVCInVC:tmVC forgetPwdBlock:^{
            
        } successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            NSLog(@"验证通过");
            self.user.verified = YES;
            [lockVC dismiss:1.0f];
        }];
    }*/
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
-(void) endOfWelcome:(id)sender
{
//    UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Main.storyboard" bundle:nil];
//    UIViewController* test2obj = [secondStoryBoard instantiateViewControllerWithIdentifier:@"test2"];  //test2为viewcontroller的StoryboardId
//    [self.navigationController pushViewController:test2obj animated:YES];
    // 此处需要清除welcome元素
    //..
    //
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self window].rootViewController = [mainStoryboard instantiateInitialViewController];
}*/

#pragma mark - MYIntroduction Delegate

-(void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    NSLog(@"Introduction did change to panel %ld", (long)panelIndex);
}

-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    NSLog(@"Introduction did finish");
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self window].rootViewController = [loginStoryboard instantiateInitialViewController];
    [KGUtil lockTopMostVC];
    //LoginViewController *loginViewController = (LoginViewController *)self.window.rootViewController;
    //loginViewController.appWindow = [self window];
    //UINavigationController *loginVC = (UINavigationController *)self.window.rootViewController;
    //loginVC. = [self window];
}

#pragma mark - webvc
- (WebViewController*)webVC
{
    if(_webVC == nil){
        _webVC = [[WebViewController alloc] init];
        
        _webVC.hidesBottomBarWhenPushed = YES;
    }
    
    return _webVC;
}

@end
