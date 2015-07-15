//
//  KGUtil.h
//  kindergarten
//
//  Created by wangbin on 15/7/9.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
@interface KGUtil : NSObject

+ (NSString *)getMD5Str: (NSString *)sourceStr;

+ (NSDictionary *)getRequestBody: (NSDictionary *)data;

+ (NSString *)getRequestSign: (NSDictionary *)body;

+(NSString *)getRequestHtmlUrl:(NSString *)controller bodyStr:(NSString *)body;
    
+ (NSString *)getCompactDateStr;

+ (void)showAlert: (NSString *)content inView:(id)view;

+ (void)showLoading: (id)view;

+ (void)postRequest: (NSString *)url
         parameters:(id)parameters
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
             inView:(UIView *)view;

+ (NSString *)getServerIndexURL;
+ (NSString *)getServerAppURL;
+ (NSString *)getServerHtmlURL;
@end
