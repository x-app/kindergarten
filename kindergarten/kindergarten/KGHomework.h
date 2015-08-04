//
//  KGHomework.h
//  kindergarten
//
//  Created by wangbin on 15/7/18.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGImageTableRowInfo.h"
//#import <UIKit/UIKit.h>
@interface KGHomework : KGImageTableRowInfo

@property (nonatomic) NSInteger classId;
@property (nonatomic) NSInteger homeworkId;

- (instancetype)initWithDesc: (NSString *)desc
                     classId: (NSInteger)classId
                  homeworkId: (NSInteger)homeworkId
                      picUrl: (NSString *)picUrl
                 smallPicUrl: (NSString *)smallPicUrl
                    createAt: (NSString *)createTime;
/*
@property (strong, nonatomic) NSString *picUrl;
@property (strong, nonatomic) NSString *smallPicUrl;
@property (strong, nonatomic) NSString *desc;
@property (nonatomic) NSInteger classId;
@property (nonatomic) NSInteger homeworkId;
@property (strong, nonatomic) NSString *createTime;

@property (strong, nonatomic) UIImage *coverImage;

- (instancetype)initWithDesc: (NSString *)desc
                     classId: (NSInteger)classId
                  homeworkId: (NSInteger)homeworkId
                      picUrl: (NSString *)picUrl
                 smallPicUrl: (NSString *)smallPicUrl
                    createAt: (NSString *)createTime;
*/
@end
