//
//  PhotoCollectionViewController.h
//  kindergarten
//
//  Created by wangbin on 15/8/11.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KGActivityAlbum.h"
#import "AlbumCollectionViewController.h"

@interface PhotoCollectionViewController : UICollectionViewController<UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) KGActivityAlbum *activityAlbum;

@property (nonatomic, weak) AlbumCollectionViewController *albumVC;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPhotoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deletePhotoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end
