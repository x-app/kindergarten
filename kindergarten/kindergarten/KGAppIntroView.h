//
//  KGAppIntroView.h
//  kindergarten
//
//  Created by wangbin on 15/8/17.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KGAppIntroViewDelegate <NSObject>

- (void)onDoneButtonPressed;

@end

@interface KGAppIntroView : UIView

@property id<KGAppIntroViewDelegate> delegate;

@end
