//
//  KGUtil.m
//  kindergarten
//
//  Created by wangbin on 15/7/9.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGUtil.h"
#import "KGConst.h"
#import "MBProgressHUD.h"
#import <CommonCrypto/CommonDigest.h>

@interface KGUtil()

@end

@implementation KGUtil


+ (NSString *)getMD5Str:(NSString *)sourceStr {
    NSData *source = [sourceStr dataUsingEncoding:NSUTF8StringEncoding ];
    NSLog(@"%@", sourceStr);
    const char *cStr = [source bytes];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSLog(@"%s", result);
    NSMutableString *digest = [ NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2 ];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat: @"%02x", result[i]];
    }
    NSLog(@"digest:%@", digest);
    return [NSString stringWithFormat:@"%@", digest];
}

+ (NSDictionary *)getRequestBody:(NSDate *)date {
    //现将时间转为2015-07-10 01:00:00的格式
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [df stringFromDate:date];
    NSDictionary *body = @{@"dateTime": dateStr};
    return body;
}

+ (NSString *)getRequestSign:(NSDate *)date {
    //现将时间转为2015-07-10 01:00:00的格式
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [df stringFromDate:date];
    //body串拼接
    NSString *bodyStr = [NSString stringWithFormat:@"{\"dateTime\":\"%@\"}%@", dateStr, REQUEST_KEY];
    return [KGUtil getMD5Str:bodyStr];
}

+ (void)showAlert:(NSString *)content inView:(id)view {
    if (![view isKindOfClass:[UIView class]]) {
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = content;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:2];
}

+ (void)showLoading:(id)view {
    if (![view isKindOfClass:[UIView class]]) {
        return;
    }
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    
    //HUD.delegate = self;
    hud.labelText = @"Loading";
    
    [hud show:YES];
    
    //[HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
}
+ (void)postRequest:(NSString *)url
         parameters:(id)parameters
            success:(void (^)(AFHTTPRequestOperation *, id))success
            failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    NSLog(@"Post request to [%@] using [%@]", url, parameters);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success != nil) {
            success(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure != nil) {
            failure(operation, error);
        }
    }];
}



@end
