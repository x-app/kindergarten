//
//  KGChild.m
//  kindergarten
//
//  Created by wangbin on 15/7/9.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGChild.h"

@implementation KGChild

- (NSDictionary *)toDictionary {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.name, @"name",
                          self.cid, @"childID",
                          self.sex, @"sex",
                          self.className, @"className",
                          self.classID, @"classID",
                          self.birthday, @"birthday",
                          nil];
    return dict;
}

- (void)fromDictionary:(NSDictionary *)dict {
    self.name = [dict objectForKey:@"name"];
    self.cid = [dict objectForKey:@"childID"];
    self.sex = [[dict objectForKey:@"sex"] integerValue];
    self.className = [dict objectForKey:@"className"];
    self.classID = [dict objectForKey:@"classID"];
    self.birthday = [dict objectForKey:@"birthday"];

}


@end
