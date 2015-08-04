//
//  ChildTableViewController.h
//  kindergarten
//
//  Created by wangbin on 15/7/18.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HOMEWORK,  //亲子成长（作业）
    TEACHER    //教师风采
} ImageTableViewType;

@interface KGImageTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *imageTableRowInfos;

@property (nonatomic) NSInteger pageIndex;

@property (nonatomic) ImageTableViewType type;

@end
