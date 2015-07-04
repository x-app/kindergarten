//
//  AppDelegate.m
//  kindergarten
//
//  Created by slice on 15-7-1.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSInteger visitTimes = 0;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    visitTimes = [userDefaults integerForKey:@"visitTimes"];
    
    //for the first time test
    visitTimes = 0;
    //
    
    if (visitTimes == 0) {
        
        //create UI
        CGRect windowFrame = [[UIScreen mainScreen] bounds];
        UIWindow *theWindow = [[UIWindow alloc] initWithFrame:windowFrame];
        [self setWindow:theWindow];
        
        CGRect buttonFrame = CGRectMake(80, 80, 80, 80);
        UIButton* _insertButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_insertButton setFrame:buttonFrame];
        
        [_insertButton addTarget:self action:@selector(endOfWelcome:) forControlEvents:UIControlEventTouchUpInside];
        
        [_insertButton setTitle:@"End" forState:UIControlStateNormal];
        [[self window] addSubview:_insertButton];
        
        [[self window] setBackgroundColor:[UIColor whiteColor]];
        [[self window] makeKeyAndVisible];

        
        visitTimes++;
    }
    
    //存储时，除NSNumber类型使用对应的类型意外，其他的都是使用setObject:forKey:
    [userDefaults setInteger:visitTimes forKey:@"visitTimes"];
    
    //这里建议同步存储到磁盘中，但是不是必须的
    [userDefaults synchronize];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


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
}


@end
