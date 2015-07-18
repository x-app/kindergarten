//
//  KGImageDetailViewController.h
//  kindergarten
//
//  Created by wangbin on 15/7/18.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KGImageDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *imageLabel;

@property (strong, nonatomic) NSString *imageDesc;
@property (strong, nonatomic) NSString *imageURL;
@end
