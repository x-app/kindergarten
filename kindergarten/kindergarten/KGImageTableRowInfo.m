//
//  KGImageTableRowInfo.m
//  kindergarten
//
//  Created by wangbin on 15/8/4.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGImageTableRowInfo.h"

@implementation KGImageTableRowInfo


- (instancetype)initWithDesc:(NSString *)desc picUrl:(NSString *)picUrl smallPicUrl:(NSString *)smallPicUrl createAt:(NSString *)createTime {
    self = [super init];
    if (self) {
        self.desc = desc;
        self.picUrl = picUrl;
        self.smallPicUrl = smallPicUrl;
        self.createTime = createTime;
    }
    return self;
}

@end
