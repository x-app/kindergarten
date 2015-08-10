//
//  ImageInfo.h
//  photobrowser
//
//  Created by wangbin on 15/7/20.
//  Copyright (c) 2015年 netmad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface PBImageInfo : NSObject

@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *imageTitle;
@property (strong, nonatomic) NSString *imageDesc;

@property (nonatomic) UIImage *placeHolder;

@property (nonatomic, strong) UIImage *image;

@end
