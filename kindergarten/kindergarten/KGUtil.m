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
#import "AppDelegate.h"
#import "UIViewController+TopMostViewController.h"
#import "CLLockVC.h"

static NSArray *month_cn;

@interface KGUtil()

@end


@implementation KGUtil


+ (NSString *)getMD5Str:(NSString *)sourceStr {
    //NSData *source = [sourceStr dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"getMD5Str.source:%@", sourceStr);
    //const char *cStr = [source bytes];
    const char *cStr = [sourceStr UTF8String];
    //NSLog(@"%d%s", strlen(cStr), cStr);
    unsigned char result[CC_MD5_DIGEST_LENGTH];// = {};
    //unsigned char *result;
    //NSLog(@"result_1:%s", result);
    //char hexDigits[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat: @"%02x", result[i]];
        //[digest appendFormat:@"%c", hexDigits[result[i] >> 4 & 0xf]];
        //[digest appendFormat:@"%c", hexDigits[result[i] & 0xf]];
    }
    NSLog(@"getMD5Str.digest:%@", digest);
    return [NSString stringWithFormat:@"%@", digest];
}

+ (NSDictionary *)getRequestBody:(NSDictionary *)data {
    NSDate *date = [[NSDate alloc] init];
    //现将时间转为2015-07-10 01:00:00的格式
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [df stringFromDate:date];
    NSMutableDictionary *body = [data mutableCopy];
    [body setObject:dateStr forKey:@"dateTime"];
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:body];
    return result;
}

+ (NSString *)getRequestSign:(NSDictionary *)body {
    //NSMutableArray *components = [[NSMutableArray alloc] init];
    //NSMutableString *bodyStr = [[NSMutableString alloc] init];
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&parseError];
    NSString *bodyStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    [bodyStr appendString:@"{"];
//    for (id key in [body allKeys]) {
//        NSString *value = [body valueForKey:key];
//        NSString *curCom = [NSString stringWithFormat:@"\"%@\":\"%@\"", key, value];
//        [components addObject:curCom];
//    }
//    [bodyStr appendString: [components componentsJoinedByString:@","]];
//    [bodyStr appendFormat:@"}"];
    //body串拼接key
    NSString *requestStr = [NSString stringWithFormat:@"%@%@", bodyStr, REQUEST_KEY];
    return [KGUtil getMD5Str:requestStr];
}

+(NSString *)getRequestHtmlUrl:(NSString *)controller bodyStr:(NSString *)bodyStr{
    NSString *str = [NSString stringWithFormat:@"%@%@", bodyStr, REQUEST_KEY];
    NSString *sign = [KGUtil getMD5Str:str];
    
    NSString *SERVER_HTML_URL = [KGUtil getServerHtmlURL];//@"http://app.nugget-nj.com/nugget";
    
    NSString *requesturl = [NSString stringWithFormat:@"%@%@?%@&sign=%@", SERVER_HTML_URL, controller, bodyStr, sign];
    
    return requesturl;
}

+(NSString *)getCompactDateStr{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateStr = [df stringFromDate:[NSDate date]];
    return dateStr;
}

+ (NSString *)getDateStr: (NSDate *)date {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [df stringFromDate:date];
    return dateStr;
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

+ (void)showCheckMark:(NSString *)infoText checked:(BOOL)checked inView:(id)view {
    if (![view isKindOfClass:[UIView class]]) {
        return;
    }
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    NSString *iconName = checked ? @"checkmark" : @"checkmark_false";
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconName]];
    
    // Set custom view mode
    hud.mode = MBProgressHUDModeCustomView;
    
    //hud.delegate = self;
    hud.labelText = infoText;
    
    [hud show:YES];
    [hud hide:YES afterDelay:2];
}

+ (void)postRequest:(NSString *)url
         parameters:(id)parameters
            success:(void (^)(AFHTTPRequestOperation *, id))success
            failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
             inView:(UIView *)view
           showHud:(BOOL)showHud
          showError:(BOOL)showError{
    NSLog(@"Post request to [%@] using [%@]", url, parameters);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10.0f;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    MBProgressHUD *hud = nil;
    if(showHud)
    {
        hud = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:hud];
        hud.labelText = @"加载中";
        hud.removeFromSuperViewOnHide = YES;
        [hud show:YES];
    }
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(showHud)
            [hud hide:YES];
        
        if (success != nil) {
            success(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(showHud)
            [hud hide:YES];
        
        if(showError)
        {
            MBProgressHUD *messageHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
            messageHUD.mode = MBProgressHUDModeText;
            NSString *content = @"";
            if (error.code == -1001) {
                content = @"请求已超时, 请检查网络设置, 稍后重试";
            } else {
                content = @"请求失败, 请稍后重试";
            }
            messageHUD.labelText = content;
            messageHUD.margin = 10.f;
            messageHUD.removeFromSuperViewOnHide = YES;
            [messageHUD hide:YES afterDelay:2];
        }
        
        if (failure != nil) {
            failure(operation, error);
        }
    }];
}

// 发送KG的数据请求
+ (void)postKGRequest:(NSString *)curl
         body:(NSDictionary *)body
            success:(void (^)(AFHTTPRequestOperation *, id))success
            failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
             inView:(UIView *)view
            showHud:(BOOL)showHud{
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:curl];

    NSDictionary *bodyhasdate = [KGUtil getRequestBody:body];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:bodyhasdate], @"body":bodyhasdate};
    
    [KGUtil postRequest:url parameters:params success:success failure:failure inView:view showHud:showHud showError:true];
}

+ (void)uploadImage:(NSString *)curl
              image:(UIImage *)image
        description:(NSString *)description
            success:(void (^)(AFHTTPRequestOperation *, id))success
            failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
             inView:(UIView *)view
            showHud:(BOOL)showHud
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = 30.0f;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    KGChild *curchild = [KGUtil getCurChild];
    NSString *childid = [NSString stringWithFormat:@"%@", curchild.cid];
    NSData *curchilddata = [childid dataUsingEncoding:NSUTF8StringEncoding];

    NSString *desc_encoded = [description stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData* descdata = [desc_encoded dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:curl];
    NSData* data = UIImagePNGRepresentation(image);
    NSLog(@"update image size is %lu", (unsigned long)[data length]);
    
    MBProgressHUD *hud = nil;
    if(showHud)
    {
        hud = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:hud];
        hud.labelText = @"正在上传...";
        hud.removeFromSuperViewOnHide = YES;
        [hud show:YES];
    }
    
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:curchilddata name:@"childId"];
        [formData appendPartWithFormData:descdata name:@"description"];
        [formData appendPartWithFileData:data name:@"picUrl" fileName:@"upload.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation,id responseObject) {
        if(showHud)
            [hud hide:YES];
        
        if (success != nil) {
            success(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        if(showHud)
            [hud hide:YES];
        
        MBProgressHUD *messageHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
        messageHUD.mode = MBProgressHUDModeText;
        NSString *content = @"";
        if (error.code == -1001) {
            content = @"请求已超时, 请检查网络设置, 稍后重试";
        } else {
            content = @"请求失败, 请稍后重试";
        }
        messageHUD.labelText = content;
        messageHUD.margin = 10.f;
        messageHUD.removeFromSuperViewOnHide = YES;
        [messageHUD hide:YES afterDelay:2];
        if (failure != nil) {
            failure(operation, error);
        }
    }];
}

+ (KGVarible *)getVarible{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.varible;
}

+ (KGUser *)getUser{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.user;
}

+ (KGChild *)getCurChild {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([delegate.user.childs count] >= 1) {
        KGChild *curChild = [delegate.user.childs objectAtIndex:0];
        return curChild;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *curchilds = [userDefaults objectForKey:@"curchilds"];

    for(int i=0; i<curchilds.count; i++)
    {
        NSDictionary *childInfo = (NSDictionary *)[curchilds objectAtIndex:i];
        
        KGChild *child = [[KGChild alloc] initWithName:[childInfo objectForKey:@"name"]
                                                       id:[childInfo objectForKey:@"id"]
                                                      sex:[[childInfo objectForKey:@"sex"] integerValue]
                                                  classID:[childInfo objectForKey:@"classId"]
                                                className:[childInfo objectForKey:@"className"]
                                                 birthday:[childInfo objectForKey:@"birthday"]];
         
        //KGChild *child = [KGChild alloc];
        //[child fromDictionary:childInfo];
        [delegate.user.childs addObject:child];
    }
    
    // TODO 选择child
    if(delegate.user.childs.count > 0)
        return delegate.user.childs[0];
    
    return nil;
}

+ (NSString *)getMonthZn:(NSInteger)index{
    if(month_cn == nil)
        month_cn = @[@"一月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月", @"九月", @"十月", @"十一月", @"十二月"];
    
    
    if(index < 1 || index > 12)
        return @"";
    return [month_cn objectAtIndex:(index-1)];
}

+ (NSString *)getServerIndexURL {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.varible.server_index_url;
}

+ (NSString *)getServerAppURL {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.varible.server_app_url;
}

+ (NSString *)getServerHtmlURL {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.varible.server_html_url;
}

+ (NSString *)getServerPushURL {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.varible.server_push_url;
}

+ (void)lockTopMostVC {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *tmVC = [[UIApplication sharedApplication] topMostViewController];
    if (tmVC == nil) {
        NSLog(@"top most vc is nil");
    }
    if ([tmVC isKindOfClass:[CLLockVC class]]) {
        NSLog(@"already locked");
        return;
    }
    if (!delegate.user.verified && !delegate.user.registering) {
        NSLog(@"用户尚未注册或者验证没过");
        [CLLockVC showVerifyLockVCInVC:tmVC forgetPwdBlock:^{
            
        } successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            NSLog(@"验证通过");
            delegate.user.verified = YES;
            [lockVC dismiss:1.0f];
        }];
    }
}

+ (UIViewController *)getTopMostViewController {
    return [[UIApplication sharedApplication] topMostViewController];
}



@end
