//
//  KGUIViewController.h
//  kindergarten
//
//  Created by wangbin on 15/7/11.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"

@interface KGUIViewController : UIViewController

- (WebViewController*)webVC;
@property (weak, nonatomic) IBOutlet UILabel *babyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *classNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *babyPortraitImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headerBgImageView;

@end
