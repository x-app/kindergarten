//
//  PhotoBrowserScrollView.h
//  photobrowser
//
//  Created by 庄小仙 on 15/7/20.
//  Copyright (c) 2015年 netmad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBImageInfo.h"
@interface PBScrollView : UIScrollView

@property (nonatomic,assign) NSUInteger index;

@property (nonatomic,strong) NSArray *imageInfos;


@end
