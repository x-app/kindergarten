//
//  WebViewController.m
//  kindergarten
//
//  Created by ShiLiangdong on 15/7/12.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@property (strong, nonatomic)UIActivityIndicatorView *activityIndicator;

@end

@implementation WebViewController

-(instancetype)init {
    self = [super init];
    
    
    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    windowFrame.size.height += 49;//height of tabbar
    
    //[self.view setFrame:windowFrame];
    //[self.view setBackgroundColor:[UIColor whiteColor]];
    
    windowFrame.size.height -= 49;
    self.webView = [[UIWebView alloc] initWithFrame:windowFrame];
    //[self.webView setBackgroundColor:[UIColor whiteColor]];
    
    
    //NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    [self.view addSubview: self.webView];
    //[self.webView loadRequest:request];
    
    [self.webView setDelegate:self];
    
    /* 没有动画效果，和navi后退并存，能退到上一功能
    UISwipeGestureRecognizer  *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [self.webView addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.webView addGestureRecognizer:swipeLeft];
    */
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after lo ading the view.
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.webView stopLoading];
    [self.webView loadHTMLString:@"" baseURL:nil];
    
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"start");
    
    //创建UIActivityIndicatorView背底半透明View
    /*CGRect windowFrame = [[UIScreen mainScreen] bounds];
    UIView *view = [[UIView alloc] initWithFrame:windowFrame];
    [view setTag:108];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.5];
    [self.view addSubview:view];*/
    
    if(self.activityIndicator == nil)
    {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [self.activityIndicator setCenter:self.webView.center];
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.webView addSubview:self.activityIndicator];
    
    
    }
    
    [self.activityIndicator startAnimating];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    //NSLog(@"finish");
    
    [self.activityIndicator stopAnimating];
    //UIView *view = (UIView*)[self.view viewWithTag:108];
    //[view removeFromSuperview];
    NSLog(@"finish");
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error");
    
    [self.activityIndicator stopAnimating];
    UIView *view = (UIView*)[self.view viewWithTag:108];
    [view removeFromSuperview];
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

@end
