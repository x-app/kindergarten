//
//  PhotoCollectionViewCell.m
//  kindergarten
//
//  Created by wangbin on 15/8/11.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@implementation PhotoCollectionViewCell

- (void)prepareImageView {
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoImageView.clipsToBounds = YES;
}

@end
