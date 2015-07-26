//
//  PBPGView.m
//  CorePhotoBroswerVC
//
//  Created by 冯成林 on 15/5/5.
//  Copyright (c) 2015年 冯成林. All rights reserved.
//

#import "PBProgressView.h"
#import "LFRoundProgressView.h"

@interface PBProgressView ()

/** 进度视图 */
@property (nonatomic,strong) LFRoundProgressView *progressView;


@end





@implementation PBProgressView


-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        
        //视图准备
        [self viewPrepare];
    }
    
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self=[super initWithCoder:aDecoder];
    
    if(self){
        
        //视图准备
        [self viewPrepare];
    }
    
    return self;
}



/*
 *  视图准备
 */
-(void)viewPrepare{
    
    self.backgroundColor = [UIColor colorWithRed:0.0/255.0f green:0.0/255.0f blue:0.0/255.0f alpha:0.5];
    
    [self addSubview:self.progressView];
    
    self.clipsToBounds = YES;
}


-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    self.layer.cornerRadius = self.bounds.size.width * .5f;
    
    
    
    CGFloat d_xy = 5.0f;
    
    self.progressView.frame = CGRectInset(self.bounds, d_xy, d_xy);
}


-(void)setProgress:(float)progress{
    
    _progress = progress;
    
    self.progressView.progress = progress;
    
    if(progress >= 1){
        [UIView animateWithDuration:.5f animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}


-(LFRoundProgressView *)progressView{
    
    if(_progressView == nil){
        
        _progressView =[[LFRoundProgressView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    }
    
    return _progressView;
}

@end
