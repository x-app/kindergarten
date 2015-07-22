//
//  ChildTableViewController.h
//  kindergarten
//
//  Created by wangbin on 15/7/18.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HOMEWORK,
    TEACHER
} ChildViewType;

@interface ChildTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *homeworks;

@property (nonatomic) NSInteger pageIndex;

@property (nonatomic) ChildViewType type;
@end
