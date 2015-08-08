//
//  WebViewController.h
//  kindergarten
//
//  Created by ShiLiangdong on 15/7/12.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;

- (void)clearWebView;

@end
