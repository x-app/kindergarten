//
//  KGClass.m
//  kindergarten
//
//  Created by wangbin on 15/8/2.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGClass.h"

@implementation KGClass

- (instancetype)initWithName:(NSString *)className classId:(NSInteger)classId {
    self = [super init];
    if (self) {
        self.className = className;
        self.classId = classId;
    }
    return self;
}

@end
