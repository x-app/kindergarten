//
//  KGChild.h
//  kindergarten
//
//  Created by wangbin on 15/7/9.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGUser.h"
@interface KGChild : NSObject

@property (strong, nonatomic) NSString *cid;        //小朋友编号
@property (strong, nonatomic) NSString *name;       //姓名
@property (nonatomic) NSInteger sex;                //性别 0女 1男
@property (strong, nonatomic) NSString *classID;    //班级ID
@property (strong, nonatomic) NSString *className;  //班级名
@property (strong, nonatomic) NSDate *birthday;     //生日
@property (weak, nonatomic) KGUser* parent;         //家长

@end
