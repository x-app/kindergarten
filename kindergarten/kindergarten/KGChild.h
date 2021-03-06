//
//  KGChild.h
//  kindergarten
//
//  Created by wangbin on 15/7/9.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGUser.h"

@interface KGChild : NSObject

@property (nonatomic) NSInteger cid;                //小朋友编号
@property (strong, nonatomic) NSString *name;       //姓名
@property (nonatomic) NSInteger sex;                //性别 0女 1男
@property (nonatomic) NSInteger classId;            //班级ID
@property (strong, nonatomic) NSString *className;  //班级名
@property (strong, nonatomic) NSString *birthday;   //生日
@property (weak, nonatomic) KGUser* parent;         //家长

- (instancetype)initWithName: (NSString *)name
                         cid: (NSInteger)cid
                         sex: (NSInteger)sex
                     classID: (NSInteger)classId
                   className: (NSString *)className
                    birthday: (NSString *)birthday;

- (NSDictionary *)toDictionary;

- (void)fromDictionary: (NSDictionary *)dict;

@end
