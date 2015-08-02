//
//  GrowupEditViewController.h
//  kindergarten
//
//  Created by ShiLiangdong on 15/7/29.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KGPostImageDelegate

-(void)reloadData;

@end

@interface GrowupEditViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, weak) UIImage *image;

@property (nonatomic, assign) id<KGPostImageDelegate> delegate;

@end
