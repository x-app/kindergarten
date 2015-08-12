//
//  ImageBrowserItemView.h
//
//  Created by wangbin on 15/7/20.
//  Copyright (c) 2015年 netmad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBImageInfo.h"
#import "PBImageView.h"
@interface PBItemView : UIView


/** 相册模型 */
@property (nonatomic,weak)  PBImageInfo *imageInfo;

/** 缩放比例回归正常 */
@property (nonatomic,assign) BOOL isScaleNormal;

/** 单击 */
@property (nonatomic,copy) void (^ItemViewSingleTapBlock)();

/** 当前的页标 */
@property (nonatomic,assign) NSUInteger pageIndex;

/** 是否有图片数据 */
@property (nonatomic,assign) BOOL hasImage;

/** 当前缩放比例 */
@property (nonatomic,assign) CGFloat zoomScale;


/** 展示照片的视图 */
@property (nonatomic,strong) PBImageView *photoImageView;



/*
 *  处理bottomView
 */
-(void)handleBottomView;



/*
 *  保存图片及回调
 */
-(void)save:(void(^)())ItemImageSaveCompleteBlock failBlock:(void(^)())failBlock;


/** 缩回正常 */
//-(void)zoomDismiss:(void(^)())compeletionBlock;



/*
 *  重置
 */
-(void)reset;

@end
