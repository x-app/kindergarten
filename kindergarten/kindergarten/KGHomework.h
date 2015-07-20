//
//  KGHomework.h
//  kindergarten
//
//  Created by wangbin on 15/7/18.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KGHomework : NSObject

@property (strong, nonatomic) NSString *picUrl;
@property (strong, nonatomic) NSString *smallPicUrl;
@property (strong, nonatomic) NSString *desc;
@property (nonatomic) NSInteger classId;
@property (nonatomic) NSInteger homeworkId;
@property (strong, nonatomic) NSString *createTime;

- (instancetype)initWithDesc: (NSString *)desc
                     classId: (NSInteger)classId
                  homeworkId: (NSInteger)homeworkId
                      picUrl: (NSString *)picUrl
                 smallPicUrl: (NSString *)smallPicUrl
                    createAt: (NSString *)createTime;

@end
