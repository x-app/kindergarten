//
//  PhotoImageView.m
//  CorePhotoBroswerVC
//
//  Created by 冯成林 on 15/5/5.
//  Copyright (c) 2015年 冯成林. All rights reserved.
//

#import "PBImageView.h"


@interface PBImageView ()

/** bounds */
@property (nonatomic,assign) CGRect screenBounds;

/** center*/
@property (nonatomic,assign) CGPoint screenCenter;

@end


@implementation PBImageView




-(void)setImage:(UIImage *)image{
    if (image == nil) {
        return;
    }
    [super setImage:image];
    
    //self.calF = UIScreen
    //确定frame
    //[self calFrame];
    
    self.contentMode = UIViewContentModeScaleAspectFit;
    
}



/*
 *  确定frame
 */
/*
-(void)calFrame{
    
    CGSize size = self.image.size;
    
    CGFloat w = size.width;
    CGFloat h = size.height;
    
    CGRect superFrame = self.screenBounds;
    CGFloat superW =superFrame.size.width ;
    CGFloat superH =superFrame.size.height;
    
    CGFloat calW = superW;
    CGFloat calH = superW;
    
    if (w>=h) {//较宽
        
        if(w> superW){//比屏幕宽
            
            CGFloat scale = superW / w;
            
            //确定宽度
            calW = w * scale;
            calH = h * scale;
            
        }else if(w <= superW){//比屏幕窄，直接居中显示
            
            calW = w;
            calH = h;
        }
        
    }else if(w<h){//较高
        
        CGFloat scale1 = superH / h;
        CGFloat scale2 = superW / w;
        
        BOOL isFat = w * scale1 > superW;//比较胖
        
        CGFloat scale =isFat ? scale2 : scale1;
 
        if(h> superH){//比屏幕高
            
            //确定宽度
            calW = w * scale;
            calH = h * scale;

        }else if(h <= superH){//比屏幕窄，直接居中显示
            
            if(w>superW){
                                    
                //确定宽度
                calW = w * scale;
                calH = h * scale;
                    
                
            }else{
                calW = w;
                calH = h;
            }
            
        }
    }
    CGFloat x = self.screenCenter.x - w *.5f;
    CGFloat y = self.screenCenter.y - h * .5f;
    CGRect frame = (CGRect){CGPointMake(x, y),CGSizeMake(calW,calH)};
       
    //self.calF = frame;
    self.calF = CGRectMake(0, 0, superW, superH);
    NSLog(@"image frame: %f %f %f %f",self.calF.origin.x, self.calF.origin.y, self.calF.size.width, self.calF.size.height);
}










-(CGRect)screenBounds{
    
    if(CGRectEqualToRect(_screenBounds, CGRectZero)){
        
        _screenBounds = [UIScreen mainScreen].bounds;
    }
    
    return _screenBounds;
}

-(CGPoint)screenCenter{
    if(CGPointEqualToPoint(_screenCenter, CGPointZero)){
        CGSize size = self.screenBounds.size;
        _screenCenter = CGPointMake(size.width * .5f, size.height * .5f);
    }

    return _screenCenter;
}
*/


@end
