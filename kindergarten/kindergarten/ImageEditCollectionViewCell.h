//
//  ImageEditCollectionViewCell.h
//  kindergarten
//
//  Created by wangbin on 15/8/9.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageEditCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageItemView;

@property (weak, nonatomic) IBOutlet UIImageView *deleteItemView;

@property (nonatomic) BOOL isAddButton;

@end
