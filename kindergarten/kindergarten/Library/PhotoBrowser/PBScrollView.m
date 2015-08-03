//
//  PhotoBrowserScrollView.m
//  photobrowser
//
//  Created by wangbin on 15/7/20.
//  Copyright (c) 2015年 netmad. All rights reserved.
//

#import "PBScrollView.h"
#import "PBItemView.h"

@interface PBScrollView()

@property (nonatomic,assign) BOOL isScrollToIndex;

@end


@implementation PBScrollView



-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    __block CGRect frame = self.bounds;
    
    CGFloat w = frame.size.width ;
    
    frame.size.width = w - 20.f;
    
    
    [self.subviews enumerateObjectsUsingBlock:^(PBItemView *photoItemView, NSUInteger idx, BOOL *stop) {
        
        CGFloat x = w * photoItemView.pageIndex;
        
        frame.origin.x = x;
        
        [UIView animateWithDuration:.01 animations:^{
            photoItemView.frame = frame;
            
        }];
        
    }];
    
    
    if(!_isScrollToIndex){
        
        //显示第index张图
        CGFloat offsetX = w * _index;
        
        [self setContentOffset:CGPointMake(offsetX, 0) animated:NO];
        
        _isScrollToIndex = YES;
    }
    
}


@end
