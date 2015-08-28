//
//  WebViewController.m
//  kindergarten
//
//  Created by ShiLiangdong on 15/7/12.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "CLLockVC.h"
#import "UIViewController+TopMostViewController.h"
#import "WebViewController.h"

@interface WebViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic)UIActivityIndicatorView *activityIndicator;

@end

@implementation WebViewController

//-(instancetype)init {
//    self = [super init];
//    
//    return self;
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    //windowFrame.size.height += 49;//height of tabbar
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate=self;
    
    [self.view addSubview: _webView];
    
    UIScrollView *scollview = (UIScrollView *)[[_webView subviews] objectAtIndex:0];
    scollview.bounces = NO;
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    
    _keepUsing = false;
    
    
    /* 没有动画效果
     UISwipeGestureRecognizer  *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
     [self.webView addGestureRecognizer:swipeRight];
     
     UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
     swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
     [self.webView addGestureRecognizer:swipeLeft];
     */
    
//    self.navigationController.delegate = self;
    
//    self.hidesBottomBarWhenPushed = YES;
    
//    self.navigationController.hidesBarsOnSwipe = YES;
    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
//    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"willappear");
//    [self.navigationController.view sendSubviewToBack:self.navigationController.navigationBar];
    // hide nav bar
//    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    // enable slide-back
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//        self.navigationController.interactivePopGestureRecognizer.delegate = self;
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"didappear");
    
    self.keepUsing = false;
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"willdisappear");
//    [self.navigationController.view bringSubviewToFront:self.navigationController.navigationBar];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"diddisappear");
    /*
    UIViewController *tmVC = [[UIApplication sharedApplication] topMostViewController];
    if (tmVC == nil) {
        return;
    }
    if ([tmVC isKindOfClass:[CLLockVC class]]) {
        //important: 防止lock出现，清空webview。
        return;
    }
    
    if(self.keepUsing)
        return;
    
    [self clearWebView];*/
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // 处理事件
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@"::"];//native::popview:
    
    if (components != nil && [components count] > 0) {
        NSString *pocotol = [components objectAtIndex:0];
        if ([pocotol isEqualToString:@"native"]) {
            NSString *commandStr = [components objectAtIndex:1];
            NSArray *commandArray = [commandStr componentsSeparatedByString:@":"];
            if (commandArray != nil && [commandArray count] > 0) {
                NSString *command = [commandArray objectAtIndex:0];
                if ([command isEqualToString:@"popview"]) {
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"消息" message:@"网页发出了登录请求" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                    [alert show];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            return NO;
        }
    }
    return YES;
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //NSLog(@"in delegate!");
    if (viewController == self) {
//        [navigationController setNavigationBarHidden:true];
    } else {
//        [navigationController setNavigationBarHidden:false];
    }
}

- (void)clearWebView
{
    [self.webView stopLoading];
    [self.webView loadHTMLString:@"" baseURL:nil];
    
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    
//    NSHTTPCookie *cookie;
//    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    for (cookie in [storage cookies]) {
//        [storage deleteCookie:cookie];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"start");
    
    if(self.activityIndicator == nil)
    {
        //创建UIActivityIndicatorView背底半透明View
        /*CGRect windowFrame = [[UIScreen mainScreen] bounds];
         UIView *view = [[UIView alloc] initWithFrame:windowFrame];
         [view setTag:108];
         [view setBackgroundColor:[UIColor blackColor]];
         [view setAlpha:0.5];
         [self.view addSubview:view];*/

        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        [self.activityIndicator setCenter:self.webView.center];
        [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.webView addSubview:self.activityIndicator];
    }
    
    [self.activityIndicator startAnimating];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
    //UIView *view = (UIView*)[self.view viewWithTag:108];
    //[view removeFromSuperview];
    NSLog(@"finish");
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error");
    
    [self.activityIndicator stopAnimating];
    //UIView *view = (UIView*)[self.view viewWithTag:108];
    //[view removeFromSuperview];
}

- (void) prevPage{
    [self.webView goBack];
}

- (void) nextPage{
    [self.webView goForward];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(void)swipe:(UISwipeGestureRecognizer *)g{
    if (g.direction == UISwipeGestureRecognizerDirectionRight) {
        [self prevPage];
    } else {
        [self nextPage];
    }
}

#pragma mark -
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (void)dealloc {
    NSLog(@"dealloc WebVC");
}

@end
