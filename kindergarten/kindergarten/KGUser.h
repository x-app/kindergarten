//
//  KGUser.h
//  kindergarten
//
//  Created by wangbin on 15/7/9.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "KGChild.h"

@interface KGUser : NSObject

@property (strong, nonatomic) NSString *uid;        //用户编号
@property (strong, nonatomic) NSString *name;       //姓名
@property (strong, nonatomic) NSString *parentID;   //家长ID
@property (strong, nonatomic) NSString *idNo;       //身份证号码
@property (strong, nonatomic) NSString *deviceID;   //设备ID
@property (nonatomic) BOOL registered;              //该用户已经注册
@property (nonatomic) BOOL verified;                //该用户已经通过手势密码验证
@property (nonatomic) BOOL registering;
@property (nonatomic) NSInteger regMode;            //0表示新用户注册 1表示找回密码

@property (nonatomic) NSInteger questionID;         //密保问题编号
@property (strong, nonatomic) NSString *question;   //密保问题
@property (strong, nonatomic) NSString *answer;     //密保问题答案

@property (strong, nonatomic) NSMutableArray *childs; //该用户的孩子

@end
