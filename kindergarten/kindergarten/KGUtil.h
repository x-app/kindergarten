//
//  KGUtil.h
//  kindergarten
//
//  Created by wangbin on 15/7/9.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KGUtil : NSObject

+ (NSString *)getMD5Str: (NSString *)sourceStr;

+ (NSString *)getRequestSign: (NSDate *)date;

@end
