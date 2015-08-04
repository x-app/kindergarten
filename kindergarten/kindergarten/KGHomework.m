//
//  KGHomework.m
//  kindergarten
//
//  Created by wangbin on 15/7/18.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGHomework.h"

@implementation KGHomework

- (instancetype)initWithDesc:(NSString *)desc classId:(NSInteger)classId homeworkId:(NSInteger)homeworkId picUrl:(NSString *)picUrl smallPicUrl:(NSString *)smallPicUrl createAt:(NSString *)createTime {
    self = [super initWithDesc:desc picUrl:picUrl smallPicUrl:smallPicUrl createAt:createTime];
    if (self) {
        //self.desc = desc;
        self.classId = classId;
        self.homeworkId = homeworkId;
        //self.picUrl = picUrl;
        //self.smallPicUrl = smallPicUrl;
        //self.createTime = createTime;
    }
    return self;
}

@end
