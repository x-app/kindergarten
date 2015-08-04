//
//  KGTeacherDesc.h
//  kindergarten
//
//  Created by wangbin on 15/8/4.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGImageTableRowInfo.h"

@interface KGTeacherDesc : KGImageTableRowInfo

@property (nonatomic) NSInteger teacherDescId;

- (instancetype)initWithDesc: (NSString *)desc
               teacherDescId: (NSInteger)teacherDescId
                      picUrl: (NSString *)picUrl
                 smallPicUrl: (NSString *)smallPicUrl
                    createAt: (NSString *)createTime;
@end
