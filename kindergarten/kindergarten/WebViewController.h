//
//  WebViewController.h
//  kindergarten
//
//  Created by ShiLiangdong on 15/7/12.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) NSString *url;

// 保留使用，这次disappear不清空
@property (nonatomic) BOOL keepUsing;

- (void)clearWebView;

@end
