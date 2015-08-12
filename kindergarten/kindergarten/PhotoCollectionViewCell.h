//
//  PhotoCollectionViewCell.h
//  kindergarten
//
//  Created by wangbin on 15/8/11.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *overlayImageView;

@property (nonatomic) BOOL isSelected;

- (void)prepareImageView;

- (void)setIsSelected:(BOOL)isSelected;

@end
