//
//  AlbumCollectionViewCell.h
//  kindergarten
//
//  Created by 庄小仙 on 15/7/28.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *album2ndImageView;
@property (weak, nonatomic) IBOutlet UIImageView *album3rdImageView;

@end
