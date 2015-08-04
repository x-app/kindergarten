//
//  HomeworkTableViewCell.h
//  kindergarten
//
//  Created by wangbin on 15/7/19.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KGImageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) NSString *smallPicUrl;
@property (strong, nonatomic) NSString *picUrl;

@end
