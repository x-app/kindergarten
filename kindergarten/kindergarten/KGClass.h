//
//  KGClass.h
//  kindergarten
//
//  Created by wangbin on 15/8/2.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KGClass : NSObject

@property (nonatomic, strong) NSString *className;
@property (nonatomic) NSInteger classId;

- (instancetype)initWithName:(NSString *)className classId:(NSInteger)classId;

- (NSDictionary *)toDictionary;

- (void)fromDictionary: (NSDictionary *)dict;

@end
