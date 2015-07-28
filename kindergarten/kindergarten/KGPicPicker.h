//
//  KGPicPicker.h
//  kindergarten
//
//  Created by ShiLiangdong on 15/7/26.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VPImageCropperViewController.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@protocol KGPicPickerDelegate

-(void)doPicPicked:(UIImage *)image;

@end

@interface KGPicPicker:NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate, VPImageCropperDelegate>

@property(nonatomic,assign) id <KGPicPickerDelegate> delegate;

-(instancetype)initWithUIVC:(UIViewController *)uiVC needCrop:(BOOL)needCrop;

-(void)takePhoto;

-(void)selectPhoto;
    
@end