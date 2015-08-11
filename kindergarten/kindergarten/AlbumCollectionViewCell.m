//
//  AlbumCollectionViewCell.m
//  kindergarten
//
//  Created by 庄小仙 on 15/7/28.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "AlbumCollectionViewCell.h"

@interface AlbumCollectionViewCell()

@end

@implementation AlbumCollectionViewCell

- (void)setImageViewsBorder {
    self.albumImageView.layer.borderWidth = 1;
    self.albumImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.album2ndImageView.layer.borderWidth = 1;
    self.album2ndImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.album3rdImageView.layer.borderWidth = 1;
    self.album3rdImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void)prepareImageViews {
    self.albumImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.albumImageView.clipsToBounds = YES;
    self.album2ndImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.album2ndImageView.clipsToBounds = YES;
    self.album3rdImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.album3rdImageView.clipsToBounds = YES;
}

@end
