//
//  GrowupEditViewController.h
//  kindergarten
//
//  Created by ShiLiangdong on 15/7/29.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ADD_GROWUP_DOC,
    ADD_HOMEWORK,
    ADD_TEACHERDESC,
    ADD_ALBUM_PHOTO
} KG_POST_TYPE;

@protocol KGPostImageDelegate

-(void)reloadData;

@end

@interface GrowupEditViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, weak) UIImage *image;

@property (nonatomic, assign) id<KGPostImageDelegate> delegate;

@property (nonatomic) KG_POST_TYPE postType;

@end
