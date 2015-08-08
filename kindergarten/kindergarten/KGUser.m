//
//  KGUser.m
//  kindergarten
//
//  Created by wangbin on 15/7/9.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGUser.h"
#import "KGChild.h"
#import "KGClass.h"
@implementation KGUser

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableArray *childDictArray = [[NSMutableArray alloc] initWithCapacity:[self.childs count]];
    for (int i = 0; i < [self.childs count]; i++) {
        NSDictionary *childDict = [self.childs[i] toDictionary];
        [childDictArray addObject:childDict];
    }
    NSMutableArray *classDictArray = [[NSMutableArray alloc] initWithCapacity:[self.classes count]];
    for (int i = 0; i < [self.classes count]; i++) {
        NSDictionary *classDict = [self.classes[i] toDictionary];
        [classDictArray addObject:classDict];
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.name, @"name",
                          self.idNo, @"idNo",
                          self.uid, @"uid",
                          @(self.parentID), @"parentID",
                          self.question, @"question",
                          @(self.questionID), @"questionID",
                          self.deviceID, @"deviceID",
                          @(self.category), @"category",
                          childDictArray, @"childs",
                          classDictArray, @"classes",
                          @(self.childIdx), @"childIdx",
                          @(self.classIdx), @"classIdx",
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
    self.questionID = [[dict objectForKey:@"questionID"] integerValue];
//    self.deviceID = [dict objectForKey:@"deviceID"];
    self.category = [[dict objectForKey:@"category"] integerValue];
    self.childIdx = [[dict objectForKey:@"childIdx"] integerValue];
    self.classIdx = [[dict objectForKey:@"classIdx"] integerValue];
//    self.answer = [dict objectForKey:@"answer"];
    //self.registered = [[dict objectForKey: @"registered"] boolValue];
    NSArray *childDictArray = [dict objectForKey:@"childs"];
    if (childDictArray != nil && childDictArray.count > 0) {
        [self.childs removeAllObjects];
        for (int i = 0; i < [childDictArray count]; i++) {
            KGChild *child = [[KGChild alloc] init];
            [child fromDictionary:childDictArray[i]];
            [self.childs addObject:child];
        }
    }
    
    NSArray *classDictArray = [dict objectForKey:@"classes"];
    if (classDictArray != nil && classDictArray.count > 0) {
        [self.classes removeAllObjects];
        for (int i = 0; i < [classDictArray count]; i++) {
            KGClass *aClass = [[KGClass alloc] init];
            [aClass fromDictionary:classDictArray[i]];
            [self.classes addObject:aClass];
        }
    }
}

- (KGChild *)getCurChild {
    if (self.childIdx < 0 || self.childIdx >= self.childs.count) {
        return nil;
    }
    return [self.childs objectAtIndex:self.childIdx];
}


- (KGClass *)getCurClass {
    if (self.classIdx < 0 || self.classIdx >= self.classes.count) {
        return nil;
    }
    return [self.classes objectAtIndex:self.classIdx];
}

- (NSMutableArray *)childs {
    if (_childs == nil) {
        _childs = [[NSMutableArray alloc] init];
    }
    return _childs;
}

- (NSMutableArray *)classes {
    if (_classes == nil) {
        _classes = [[NSMutableArray alloc] init];
    }
    return _classes;
}

@end
