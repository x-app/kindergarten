//
//  KGUser.m
//  kindergarten
//
//  Created by wangbin on 15/7/9.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGUser.h"
#import "KGChild.h"

@implementation KGUser

- (instancetype)init {
    self = [super init];
    self.childs = [[NSMutableArray alloc] init];
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableArray *dictArray = [[NSMutableArray alloc] initWithCapacity:[self.childs count]];
    for (int i = 0; i < [self.childs count]; i++) {
        NSDictionary *childDict = [self.childs[i] toDictionary];
        [dictArray addObject:childDict];
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.name, @"name",
                          self.idNo, @"idNo",
                          self.uid, @"uid",
                          [NSString stringWithFormat: @"%ld", (long)self.parentID], @"parentID",
                          self.question, @"question",
//                          self.questionID, @"questionID",
//                          self.deviceID, @"deviceID",
                          [NSString stringWithFormat: @"%ld", (long)self.category], @"category",
//                          self.answer, @"answer",
                          //self.registered, @"registered",
                          //self.childs, dictArray,
                          nil];
    
    return dict;
}

- (void)fromDictionary:(NSDictionary *)dict {
    self.name = [dict objectForKey:@"name"];
    self.idNo = [dict objectForKey:@"idNo"];
    self.uid = [dict objectForKey:@"uid"];
    self.parentID = [[dict objectForKey:@"parentID"] integerValue];
    self.question = [dict objectForKey:@"question"];
//    self.questionID = [[dict objectForKey:@"questionID"] integerValue];
//    self.deviceID = [dict objectForKey:@"deviceID"];
    self.category = [[dict objectForKey:@"category"] integerValue];
//    self.answer = [dict objectForKey:@"answer"];
    //self.registered = [[dict objectForKey: @"registered"] boolValue];
    /*
    NSArray *childArray = [[dict objectForKey:@"childs"] array];
    for (int i = 0; i < [childArray count]; i++) {
        KGChild *child = [[KGChild alloc] init];
        [child fromDictionary:childArray[i]];
        [self.childs addObject:child];
    }*/
}
@end
