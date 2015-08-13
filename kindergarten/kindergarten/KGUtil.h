//
//  KGUtil.h
//  kindergarten
//
//  Created by wangbin on 15/7/9.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "KGChild.h"
#import "KGVarible.h"
#import "KGClass.h"
#import "WebViewController.h"

#define __BASE64( text )        [KGUtil base64StringFromText:text]
#define __TEXT( base64 )        [KGUtil textFromBase64String:base64]

@interface KGUtil : NSObject

+ (BOOL)isTeacherVersion;

+ (void)setAppVersion:(NSInteger)version;

+ (NSString *)getMD5Str: (NSString *)sourceStr;

+ (NSDictionary *)getRequestBody: (NSDictionary *)data;

+ (NSString *)getRequestSign: (NSDictionary *)body;

+(NSString *)getRequestHtmlUrl:(NSString *)controller bodyStr:(NSString *)body;

+ (NSString *)getCompactDateStr;

+ (NSString *)getDateStr: (NSDate *)date;

+ (NSString *)getChnDateStr: (NSDate *)date;

+ (void)showAlert:(NSString *)content inView:(id)view;

+ (void)showLoading:(NSString *)title inView:(id)view;

+ (void)showCheckMark:(NSString *)infoText checked:(BOOL)checked inView:(id)view;

+ (UIViewController *)getTopMostViewController;

+(void)sendGetRequest:(NSString *)url
              success:(void (^)(AFHTTPRequestOperation *, id))success
              failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;

+ (void)postRequest: (NSString *)url
         parameters:(id)parameters
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
             inView:(UIView *)view
            showHud:(BOOL)showHud
          showError:(BOOL)showError;

+ (void)postKGRequest:(NSString *)curl
                 body:(NSDictionary *)body
              success:(void (^)(AFHTTPRequestOperation *, id))success
              failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
               inView:(UIView *)view
              showHud:(BOOL)showHud;

+ (void)uploadImage:(NSString *)curl
             images:(NSArray *)images
        description:(NSString *)description
         customAttr:(NSString *)customAttr
        customValue:(NSData *)customValue
            success:(void (^)(AFHTTPRequestOperation *, id))success
            failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
             inView:(UIView *)view
            showHud:(BOOL)showHud;

+ (KGVarible *)getVarible;
+ (KGChild *)getCurChild;
+ (KGClass *)getCurClass;
+ (NSInteger)getCurClassId;
+ (KGUser *)getUser;

+ (NSString *)getMonthZn:(NSInteger)index;

+ (NSString *)getServerIndexURL;

+ (NSString *)getServerAppURL;

+ (NSString *)getServerHtmlURL;

+ (NSString *)getServerPushURL;

+ (WebViewController *)getWebVC;

+ (void)pushWebView:(NSString *)webViewType inViewController:(UIViewController*)vc;
+ (void)pushWebViewWithUrl:(NSString *)url inViewController:(UIViewController*)vc;

+ (void)lockTopMostVC;

+ (void)pushViewByNotification;

+ (BOOL)isEmptyString:(NSString *)str;

/******************************************************************************
 函数名称 : + (NSString *)base64StringFromText:(NSString *)text
 函数描述 : 将文本转换为base64格式字符串
 输入参数 : (NSString *)text    文本
 输出参数 : N/A
 返回参数 : (NSString *)    base64格式字符串
 备注信息 :
 ******************************************************************************/
+ (NSString *)base64StringFromText:(NSString *)text;

/******************************************************************************
 函数名称 : + (NSString *)textFromBase64String:(NSString *)base64
 函数描述 : 将base64格式字符串转换为文本
 输入参数 : (NSString *)base64  base64格式字符串
 输出参数 : N/A
 返回参数 : (NSString *)    文本
 备注信息 :
 ******************************************************************************/
+ (NSString *)textFromBase64String:(NSString *)base64;

@end
