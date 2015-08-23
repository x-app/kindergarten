//
//  AlbumCollectionViewController.h
//  kindergarten
//
//  Created by 庄小仙 on 15/7/28.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumCollectionViewController : UICollectionViewController<UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *activityAlbums;

@end
