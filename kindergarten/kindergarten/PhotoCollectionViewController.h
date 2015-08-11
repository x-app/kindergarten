//
//  PhotoCollectionViewController.h
//  kindergarten
//
//  Created by wangbin on 15/8/11.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KGActivityAlbum.h"

@interface PhotoCollectionViewController : UICollectionViewController<UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) KGActivityAlbum *activityAlbum;

@end
