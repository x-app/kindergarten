//
//  KGPicPicker.h
//  kindergarten
//
//  Created by ShiLiangdong on 15/7/26.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VPImageCropperViewController.h"
#import "ELCImagePickerHeader.h"
#define ORIGINAL_MAX_WIDTH 640.0f

@protocol KGPicPickerDelegate

//-(void)doPicPicked:(UIImage *)image;

//单选模式时取索引为0的UIImage
- (void)doPicPicked:(NSArray *)images;
@end

@interface KGPicPicker:NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate, VPImageCropperDelegate, ELCImagePickerControllerDelegate>

@property(nonatomic,assign) id <KGPicPickerDelegate> delegate;

@property(nonatomic) NSInteger maxNumber;

-(instancetype)initWithUIVC:(UIViewController *)uiVC needCrop:(BOOL)needCrop;

-(instancetype)initWithUIVC:(UIViewController *)uiVC needCrop:(BOOL)needCrop multiple:(BOOL)multiple;

-(void)takePhoto;

-(void)selectPhoto;
    
@end