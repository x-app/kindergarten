//
//  KGTeacherDesc.m
//  kindergarten
//
//  Created by wangbin on 15/8/4.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGTeacherDesc.h"

@implementation KGTeacherDesc

- (instancetype)initWithDesc:(NSString *)desc teacherDescId:(NSInteger)teacherDescId picUrl:(NSString *)picUrl smallPicUrl:(NSString *)smallPicUrl createAt:(NSString *)createTime {
    self = [super initWithDesc:desc picUrl:picUrl smallPicUrl:smallPicUrl createAt:createTime];
    if (self) {
        self.teacherDescId = teacherDescId;
    }
    return self;
}

@end
