//
//  IntroductionViewController.h
//  kindergarten
//
//  Created by 庄小仙 on 15/7/22.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CLASS,
    GARTEN
} IntroductionViewType;

@interface IntroductionViewController : UIViewController

@property (nonatomic) IntroductionViewType type;

@property (strong, nonatomic) NSString *smallPicUrl;
@property (strong, nonatomic) NSString *picUrl;
@property (strong, nonatomic) NSString *introContent;

@property (weak, nonatomic) IBOutlet UIImageView *introImageView;

@property (weak, nonatomic) IBOutlet UITextView *introTextView;

@end
