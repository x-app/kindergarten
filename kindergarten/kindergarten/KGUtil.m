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
    
    [hud hide:YES afterDelay:3];
}

/*
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
    
    [hud hide:YES afterDelay:3];
}*/



@end
