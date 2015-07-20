//
//  KGImageDetailViewController.m
//  kindergarten
//
//  Created by wangbin on 15/7/18.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGImageDetailViewController.h"
//#import "UIImageView+WebCache.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
@interface KGImageDetailViewController ()

@end

@implementation KGImageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.imageURL = @"http://i1.hoopchina.com.cn/u/1306/16/662/31662/4c3059fc.gif";
    //self.imageDesc = @"MJ block";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.imageURL) {
        __block UIActivityIndicatorView *activityIndicator;
        __weak UIImageView *weakImageView = self.imageView;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.imageURL]
                          placeholderImage:nil
                                   options:SDWebImageProgressiveDownload
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                      NSLog(@">>>>");
                                      if (!activityIndicator) {
                                          activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                                          [weakImageView addSubview:activityIndicator];
                                          activityIndicator.center = weakImageView.center;
                                          [activityIndicator startAnimating];
                                      }
                                  }
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     NSLog(@"load image compelted");
                                     [activityIndicator removeFromSuperview];
                                     activityIndicator = nil;
                                 }];
        /*[self.imageView setImageWithURL:[NSURL URLWithString:self.imageURL]
                       placeholderImage:nil//[UIImage imageNamed:@"image_placeholder"]
                                options:SDWebImageProgressiveDownload
                               progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                   //
                                   NSLog(@"%ld%ld", (long)receivedSize, (long)expectedSize);
                               } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   //
                               } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];*/
    }
    if (self.imageDesc) {
        self.imageLabel.text = self.imageDesc;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
