//
//  AppDelegate.m
//  kindergarten
//
//  Created by slice on 15-7-1.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "AppDelegate.h"
#import "KGUtil.h"
//#import "MYBlurIntroductionView.h"

@interface AppDelegate ()

//app退出激活状态时的时间(按home键退出,下拉通知菜单, 上拉控制中心时触发)
@property (nonatomic, strong) NSDate *resignActiveTime;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //设置全局导航条风格和颜色
//    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1]];
//    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    
    // IOS8 新系统需要使用新的代码咯
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:
            [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                              categories:nil]];
        
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        //这里还是原来的代码
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:

         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    // get push
    self.isLaunchedByNotification = false;
    self.pushUrl = @"";
    self.pushFunc = @"";
    if (launchOptions != nil)
    {
        self.isLaunchedByNotification = true;
        NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            //NSLog(@"Launched from push notification: %@", dictionary);
            //dictionary是payload
            [self doWithNotification:dictionary];
        }
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger versionInUD  = [[userDefaults objectForKey:@"appVersion"] integerValue];
    self.appVersion = versionInUD;
    
    self.resignActiveTime = nil;
    // 修复Push到下一级右上角可恶的黑条
    self.window.backgroundColor = [UIColor whiteColor];
    self.user = [[KGUser alloc] init];
    self.user.verified = NO;
    self.user.registered = NO;
    self.user.deviceID = @"";
    NSDictionary *userDict = [userDefaults objectForKey:@"user"];
    if (userDict != nil) {
        [self.user fromDictionary:userDict];
    }
    
    self.varible = [[KGVarible alloc] init];
    self.varible.server_index_url = @"http://app.nugget-nj.com/kindergarten_index";
    //self.varible.server_app_url = @"http://app.nugget-nj.com/nugget_app";
    self.varible.server_push_url = @"http://slice.eu.org:8080/pushservice/api";
        
    NSDictionary *variDict = [userDefaults objectForKey:@"varible"];
    if (variDict != nil) {
        [self.varible fromDictionary:variDict];
    }
    
    NSInteger visitTimes = [userDefaults integerForKey:@"visitTimes"];
    
//    for the first time test
    //visitTimes = 0;
    //
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
    
    NSLog(@"did become active in AppDelegate");
    

    
    self.user.verified = NO;
    NSDate *curTime = [[NSDate alloc] init];
    //第一次进入系统或者非激活状态超过一分钟，返回时需要重新lock
    if (self.resignActiveTime == nil || [curTime timeIntervalSinceDate:self.resignActiveTime] > 0) {
        [KGUtil lockTopMostVC];
    }
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
    
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }
    }
    
    return _webVC;
}

#pragma mark - push
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    
    NSString *newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    self.devicetoken = newToken;
    [self postToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)payload
{
    NSLog(@"Received notification: %@", payload);
    self.isLaunchedByNotification = false;
    
    [self doWithNotification:payload];
    
    if (application.applicationState == UIApplicationStateActive)
    {//程序当前正处于前台
        NSLog(@"Received notification active");
        
        //弹出是否打开推送页面
        UIAlertView *hint = [[UIAlertView alloc] initWithTitle:@"请确认" message:@"收到推送通知，是否打开推送页面?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [hint show];
    }
    else if(application.applicationState == UIApplicationStateInactive)
    {//点击通知启动，程序在后台。进入这里
        NSLog(@"Received notification inactive");

        //热启动时，执行推送到指定页面
        //self.isLaunchedByNotification = true;//从后台激活同冷启动一样处理
        [KGUtil pushViewByNotification];
//        self.isLaunchedByNotification = false;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [KGUtil pushViewByNotification];
    }
}

- (void)doWithNotification:(NSDictionary*)payload
{
//    NSString *alertValue = [[payload valueForKey:@"aps"] valueForKey:@"alert"];

    // 自定义消息
    NSString *url = [payload valueForKey:@"url"];
    NSString *func = [payload valueForKey:@"func"];
    
//    NSInteger badge = -1;
//    if([[payload allKeys] containsObject:@"badge"])
//        badge = [[payload valueForKey:@"badge"] integerValue];
    
    self.pushUrl = url;
    self.pushFunc = func;
}

-(void)postToken
{
    if(self.user != nil && ![KGUtil isEmptyString:self.user.uid] && ![KGUtil isEmptyString:self.devicetoken])
    {
        NSString *name = self.user.name;
        if(name == nil)
            name = @"";
        
        NSDictionary *data = @{@"uid": self.user.uid,
                               @"token": self.devicetoken,
                               @"name": name};
        NSDictionary *body = [KGUtil getRequestBody:data];
        NSDictionary *params = @{@"type": @"JOIN", @"sign": [KGUtil getRequestSign:body], @"body": body};
        
        [KGUtil postRequest:[KGUtil getServerPushURL] parameters:params
                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSLog(@"submit token succ!");
                    }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error: %@", error);
                    }
                     inView:nil showHud:false showError:false];
    }
}

-(void)deleteToken
{
    if(![KGUtil isEmptyString:self.lastUID] && ![KGUtil isEmptyString:self.devicetoken])
    {
        NSDictionary *data = @{@"uid": self.lastUID,
                               @"token": self.devicetoken};
        NSDictionary *body = [KGUtil getRequestBody:data];
        NSDictionary *params = @{@"type": @"LEAVE", @"sign": [KGUtil getRequestSign:body], @"body": body};
        
        [KGUtil postRequest:[KGUtil getServerPushURL] parameters:params
                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSLog(@"delete token succ!");
                    }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error: %@", error);
                    }
                     inView:nil showHud:false showError:false];
    }
}

-(void)replaceToken:(void (^)())success
failure:(void (^)())failure
{
    if(![KGUtil isEmptyString:self.devicetoken] && self.user != nil &&
       ![KGUtil isEmptyString:self.user.uid])
    {
        if(self.lastUID == nil)
            self.lastUID = @"";
        
        NSString *name = self.user.name;
        if(name == nil)
            name = @"";

        NSDictionary *data = @{@"delete_uid": self.lastUID,
                               @"delete_token": self.devicetoken,
                               @"uid": self.user.uid,
                               @"token": self.devicetoken,
                               @"name": name};
        NSDictionary *body = [KGUtil getRequestBody:data];
        NSDictionary *params = @{@"type": @"REPLACE", @"sign": [KGUtil getRequestSign:body], @"body": body};
        
        [KGUtil postRequest:[KGUtil getServerPushURL] parameters:params
                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSLog(@"replace token succ!");
                        success();
                    }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"replace token failure: %@", error);
                        failure();
                    }
                     inView:nil showHud:false showError:false];
    }
}


@end
