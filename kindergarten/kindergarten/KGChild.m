//
//  KGChild.m
//  kindergarten
//
//  Created by wangbin on 15/7/9.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGChild.h"

@implementation KGChild

- (instancetype)initWithName:(NSString *)name id:(NSString *)id sex:(NSInteger)sex classID:(NSInteger)classId className:(NSString *)className birthday:(NSString *)birthday {
    self = [super init];
    if (self) {
        self.name = name;
        self.cid = id;
        self.sex = sex;
        self.classId = classId;
        self.className = className;
        self.birthday = birthday;
        self.parent = nil;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.name, @"name",
                          self.cid, @"childID",
                          self.sex, @"sex",
                          self.className, @"className",
                          self.classId, @"classID",
                          self.birthday, @"birthday",
                          nil];
    return dict;
}

- (void)fromDictionary:(NSDictionary *)dict {
    self.name = [dict objectForKey:@"name"];
    self.cid = [dict objectForKey:@"childID"];
    self.sex = [[dict objectForKey:@"sex"] integerValue];
    self.className = [dict objectForKey:@"className"];
    self.classId = [[dict objectForKey:@"classID"] integerValue];
    self.birthday = [dict objectForKey:@"birthday"];
}


@end
