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

- (NSDictionary *)toDictionary {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.className, @"className",
                          @(self.classId), @"classID",
                          nil];
    return dict;
}

- (void)fromDictionary:(NSDictionary *)dict {
    self.classId = [[dict objectForKey:@"classID"] integerValue];
    self.className = [dict objectForKey:@"className"];
}

@end
