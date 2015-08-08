//
//  KGUser.h
//  kindergarten
//
//  Created by wangbin on 15/7/9.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KGChild;
@class KGClass;

@interface KGUser : NSObject

@property (strong, nonatomic) NSString *uid;        //用户编号
@property (strong, nonatomic) NSString *name;       //姓名
@property (nonatomic) NSInteger parentID;           //家长ID(如果是教师则有)
@property (nonatomic) NSInteger teacherID;          //教师ID(如果是教师则有)
@property (strong, nonatomic) NSString *idNo;       //身份证号码
@property (strong, nonatomic) NSString *deviceID;   //设备ID
@property (nonatomic) NSInteger category;           //用户类别300-家长 301-教师 302-园长
@property (nonatomic) BOOL registered;              //该用户已经注册
@property (nonatomic) BOOL verified;                //该用户已经通过手势密码验证
@property (nonatomic) BOOL registering;
@property (nonatomic) NSInteger regMode;            //0表示新用户注册 1表示找回密码

@property (nonatomic) NSInteger questionID;         //密保问题编号
@property (strong, nonatomic) NSString *question;   //密保问题
@property (strong, nonatomic) NSString *answer;     //密保问题答案

@property (strong, nonatomic) NSMutableArray *childs;  //该用户的孩子(适用于家长)
//@property (strong, nonatomic) KGChild *curChild;
@property (nonatomic) NSInteger childIdx;           //当前小孩的索引
@property (strong, nonatomic) NSMutableArray *classes; //该用户的班级(适用于教师)
@property (nonatomic) NSInteger classIdx;           //当前班级的索引

- (NSDictionary *)toDictionary;

- (void)fromDictionary: (NSDictionary *)dict;

- (KGChild *)getCurChild;

- (KGClass *)getCurClass;

@end
