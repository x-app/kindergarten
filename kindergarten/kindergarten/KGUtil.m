//
//  KGUtil.m
//  kindergarten
//
//  Created by wangbin on 15/7/9.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGUtil.h"
#import "KGUIViewController.h"
#import "KGConst.h"
#import "MBProgressHUD.h"
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"
#import "UIViewController+TopMostViewController.h"
#import "CLLockVC.h"
//引入IOS自带密码库
#import <CommonCrypto/CommonCryptor.h>

static NSArray *month_cn;

@interface KGUtil()

@end


@implementation KGUtil

+ (BOOL)isTeacherVersion
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return (delegate.appVersion == 1);
    //return true;
}

+ (void)setAppVersion:(NSInteger)version {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (version != 0 && version != 1) {
        version = 0; //若非0和1,默认取0家长版
    }
    delegate.appVersion = version;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(delegate.appVersion) forKey:@"appVersion"];
    [userDefaults synchronize];
}

+ (NSInteger)getAppVersionFromUserDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults objectForKey:@"appVersion"] integerValue];
}

+ (NSString *)getMD5Str:(NSString *)sourceStr {
    //NSData *source = [sourceStr dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"getMD5Str.source:%@", sourceStr);
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
//    NSLog(@"getMD5Str.digest:%@", digest);
    return [NSString stringWithFormat:@"%@", digest];
}

+ (NSDictionary *)getRequestBody:(NSDictionary *)data {
    //NSDate *date = [[NSDate alloc] init];
    NSDate *date = [NSDate date];
    NSTimeZone* chinaZone = [NSTimeZone timeZoneForSecondsFromGMT:8*3600]; //转化到我们所在的东八区时间
    //现将时间转为2015-07-10 01:00:00的格式
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [df setTimeZone:chinaZone];
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
    bodyStr = [bodyStr stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
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

+ (NSString *)getChnDateStr: (NSDate *)date {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy年MM月dd日"];
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
    hud.labelFont = [UIFont systemFontOfSize:14];
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:2];
}

+ (void)showLoading:(NSString *)title inView:(id)view {
    if (![view isKindOfClass:[UIView class]]) {
        return;
    }
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    
    //HUD.delegate = self;
    hud.labelText = [KGUtil isEmptyString:title] ? @"Loading" : title;
    hud.labelFont = [UIFont systemFontOfSize:13];
    hud.removeFromSuperViewOnHide = YES;
    [hud show:YES];
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
    hud.labelFont = [UIFont systemFontOfSize:14];
    
    [hud show:YES];
    [hud hide:YES afterDelay:1];
}

+ (KGVarible *)getVarible{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.varible;
}

+ (KGUser *)getUser{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.user;
}

+ (NSInteger)getUserCatagory {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate == nil || delegate.user == nil) {
        return -1;
    }
    if (delegate.user.category == 300) {
        return 0;
    } else if (delegate.user.category == 301) {
        return 2;
    } else if (delegate.user.category == 302) {
        return 1;
    } else {
        return -1;
    }
}

+ (NSInteger)getCurClassId {
    if ([KGUtil isTeacherVersion]) {
        return [KGUtil getCurClass].classId;
    } else {
        return [KGUtil getCurChild].classId;
    }
}

+ (void)setCurClassId:(NSInteger)index
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (index > 0 && index < [delegate.user.classes count]) {
        delegate.user.classIdx = index;
    }
}

+ (NSMutableArray *)getClasses
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.user.classes;
}

+ (KGClass *)getCurClass {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([delegate.user.classes count] >= 1) {
        return [delegate.user getCurClass];
    }
    /*if ([delegate.user.classes count] >= 1) {
        KGClass *curClass = [delegate.user.classes objectAtIndex:0];
        return curClass;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *curclasses = [userDefaults objectForKey:@"curclasses"];
    
    for(int i=0; i<curclasses.count; i++)
    {
        NSDictionary *classInfo = (NSDictionary *)[curclasses objectAtIndex:i];
        
        KGClass *aClass = [[KGClass alloc] initWithName:[classInfo objectForKey:@"className"]
                                                classId:[[classInfo objectForKey:@"classId"] integerValue]];
        [delegate.user.classes addObject:aClass];
    }
    
    // TODO 选择class
    if(delegate.user.classes.count > 0)
        return delegate.user.classes[0];
     */
    return nil;
}

+ (NSMutableArray *)getChilds {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.user.childs;
}

+ (KGChild *)getCurChild {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([delegate.user.childs count] >= 1) {
        return [delegate.user getCurChild];
    }
    /*if ([delegate.user.childs count] >= 1) {
        KGChild *curChild = [delegate.user.childs objectAtIndex:0];
        return curChild;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *curchilds = [userDefaults objectForKey:@"curchilds"];

    for(int i=0; i<curchilds.count; i++)
    {
        NSDictionary *childInfo = (NSDictionary *)[curchilds objectAtIndex:i];
        
        KGChild *child = [[KGChild alloc] initWithName:[childInfo objectForKey:@"name"]
                                                   cid:[[childInfo objectForKey:@"id"] integerValue]
                                                   sex:[[childInfo objectForKey:@"sex"] integerValue]
                                               classID:[[childInfo objectForKey:@"classId"] integerValue]
                                             className:[childInfo objectForKey:@"className"]
                                              birthday:[childInfo objectForKey:@"birthday"]];
         
        //KGChild *child = [KGChild alloc];
        //[child fromDictionary:childInfo];
        [delegate.user.childs addObject:child];
    }
    
    // TODO 选择child
    if(delegate.user.childs.count > 0)
        return delegate.user.childs[0];
    */
    return nil;
}

+ (void)setCurChildId:(NSInteger)index
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (index > 0 && index < [delegate.user.childs count]) {
        delegate.user.childIdx = index;
    }
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

//+ (WebViewController *)getWebVC
//{
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    return delegate.webVC;
//}

+ (UIViewController *)getTopMostViewController {
    return [[UIApplication sharedApplication] topMostViewController];
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

+ (BOOL)isEmptyString:(NSString *)str {
    return (str == nil) || [str isKindOfClass:[NSNull class]] || [str isEqualToString:@""];
}

///base64相关函数
//空字符串
#define     LocalStr_None           @""

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

+ (NSString *)base64StringFromText:(NSString *)text
{
    if (text && ![text isEqualToString:LocalStr_None]) {
        //取项目的bundleIdentifier作为KEY  改动了此处
        //NSString *key = [[NSBundle mainBundle] bundleIdentifier];
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        //IOS 自带DES加密 Begin  改动了此处
        //data = [self DESEncrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [self base64EncodedStringFrom:data];
    }
    else {
        return LocalStr_None;
    }
}

+ (NSString *)textFromBase64String:(NSString *)base64
{
    if (base64 && ![base64 isEqualToString:LocalStr_None]) {
        //取项目的bundleIdentifier作为KEY   改动了此处
        //NSString *key = [[NSBundle mainBundle] bundleIdentifier];
        NSData *data = [self dataWithBase64EncodedString:base64];
        //IOS 自带DES解密 Begin    改动了此处
        //data = [self DESDecrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else {
        return LocalStr_None;
    }
}

/******************************************************************************
 函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES加密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 ******************************************************************************/
+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

/******************************************************************************
 函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES解密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 ******************************************************************************/
+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

/******************************************************************************
 函数名称 : + (NSData *)dataWithBase64EncodedString:(NSString *)string
 函数描述 : base64格式字符串转换为文本数据
 输入参数 : (NSString *)string
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 :
 ******************************************************************************/
+ (NSData *)dataWithBase64EncodedString:(NSString *)string
{
    if (string == nil)
        [NSException raise:NSInvalidArgumentException format:nil];
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

/******************************************************************************
 函数名称 : + (NSString *)base64EncodedStringFrom:(NSData *)data
 函数描述 : 文本数据转换为base64格式字符串
 输入参数 : (NSData *)data
 输出参数 : N/A
 返回参数 : (NSString *)
 备注信息 :
 ******************************************************************************/
+ (NSString *)base64EncodedStringFrom:(NSData *)data
{
    if ([data length] == 0)
        return @"";
    
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
            buffer[bufferLength++] = ((char *)[data bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

#pragma mark - request

+(void)sendGetRequest:(NSString *)url
              success:(void (^)(AFHTTPRequestOperation *, id))success
              failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSLog(@"send get request to [%@]", url);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10.0f;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:url parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject){
             if (success != nil) {
                 success(operation, responseObject);
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error){
             if (failure != nil) {
                 failure(operation, error);
             }
         }];
    
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
    if (view == nil) {
        showHud = NO;
    }
    MBProgressHUD *hud = nil;
    if(showHud)
    {
        hud = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:hud];
        hud.labelText = @"加载中";
        hud.labelFont = [UIFont systemFontOfSize:14];
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
            hud.labelFont = [UIFont systemFontOfSize:14];
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
/*
+ (void)uploadImage:(NSString *)curl
              image:(UIImage *)image
        description:(NSString *)description
         customAttr:(NSString *)customAttr
        customValue:(NSData *)customValue
            success:(void (^)(AFHTTPRequestOperation *, id))success
            failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
             inView:(UIView *)view
            showHud:(BOOL)showHud
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = 30.0f;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    //KGChild *curchild = [KGUtil getCurChild];
    //NSString *childid = [NSString stringWithFormat:@"%@", curchild.cid];
    //NSData *curchilddata = [childid dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *desc_encoded = [description stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData* descdata = [desc_encoded dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:curl];
    //    NSData* data = UIImagePNGRepresentation(image);
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSLog(@"uplaod image size of fatctor 1.0 is %lu", (unsigned long)[data length]);
    
    float factor = 0.9;
    while([data length] >= 1000000 && factor > 0)
    {
        data = UIImageJPEGRepresentation(image, factor);
        NSLog(@"upload image size of factor %f is %lu", factor, (unsigned long)[data length]);
        factor -= 0.1;
    }
    
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
        //[formData appendPartWithFormData:curchilddata name:@"childId"];
        if (customAttr && customValue) {
            [formData appendPartWithFormData:customValue name:customAttr];
        }
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
*/
/*
+ (void)uploadImage:(NSString *)curl
             images:(NSArray *)images
        description:(NSString *)description
         customAttr:(NSString *)customAttr
        customValue:(NSData *)customValue
            success:(void (^)(AFHTTPRequestOperation *, id))success
            failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
             inView:(UIView *)view
            showHud:(BOOL)showHud
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = 30.0f;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    //KGChild *curchild = [KGUtil getCurChild];
    //NSString *childid = [NSString stringWithFormat:@"%@", curchild.cid];
    //NSData *curchilddata = [childid dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *desc_encoded = [description stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData* descdata = [desc_encoded dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:curl];
    //    NSData* data = UIImagePNGRepresentation(image);
    NSMutableData *imageData = [[NSMutableData alloc] init];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < images.count; i++) {
        UIImage *image = [images objectAtIndex:i];
        if (image == nil) {
            continue;
        }
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        NSLog(@"uplaod image size of fatctor 1.0 is %lu", (unsigned long)[data length]);
        
        float factor = 0.9;
        while([data length] >= 1000000 && factor > 0)
        {
            data = UIImageJPEGRepresentation(image, factor);
            NSLog(@"upload image size of factor %f is %lu", factor, (unsigned long)[data length]);
            factor -= 0.1;
        }
        [dataArray addObject:data];
        [imageData appendData:data];
    }
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
        //[formData appendPartWithFormData:curchilddata name:@"childId"];
        if (customAttr && customValue) {
            [formData appendPartWithFormData:customValue name:customAttr];
        }
        [formData appendPartWithFormData:descdata name:@"description"];
        for (int i = 0; i < dataArray.count; i++) {
            //NSString *name = [NSString stringWithFormat:@"picUrl%d", i];
            NSString *file = [NSString stringWithFormat:@"upload%d.jpg", i];
            [formData appendPartWithFileData:dataArray[i] name:@"picUrl" fileName:file mimeType:@"image/jpeg"];
        }
        //[formData appendPartWithFileData:imageData name:@"picUrl" fileName:@"upload.jpg" mimeType:@"image/jpeg"];
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
*/

+ (void)uploadImage:(NSString *)curl
             images:(NSArray *)images
        description:(NSString *)description
         customAttr:(NSString *)customAttr
        customValue:(NSData *)customValue
            success:(void (^)(AFHTTPRequestOperation *, id))success
            failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
             inView:(UIView *)view
            showHud:(BOOL)showHud
{
    if (images == nil || images.count == 0) {
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = 30.0f;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString *desc_encoded = [description stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData* descdata = [desc_encoded dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:curl];
    
    NSInteger imagesCount = images.count;
    NSLog(@"====>%ld个图片等待上传", (long)imagesCount);
    
    //取出第一个UIImage上传
    UIImage *image = [images objectAtIndex:0];
    //除了第一个之外的其他images重新作为一个数组递归上传
    NSArray *otherImages = nil;
    if (imagesCount > 1) {
        NSIndexSet *otherIdxs = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(1, imagesCount - 1)];
        otherImages = [images objectsAtIndexes:otherIdxs];
    }
    if (image == nil) {
        //递归上传下一个图片
        [KGUtil uploadImage:curl images:otherImages description:description customAttr:customAttr customValue:customValue success:success failure:failure inView:view showHud:showHud];
        return;
    }
    //压缩图片至1MB以内
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    //NSLog(@"upload image size of fatctor 1.0 is %lu", (unsigned long)[data length]);
    float factor = 0.9;
    while([data length] >= 1000000 && factor > 0)
    {
        data = UIImageJPEGRepresentation(image, factor);
        //NSLog(@"upload image size of factor %f is %lu", factor, (unsigned long)[data length]);
        factor -= 0.1;
    }
    
    MBProgressHUD *hud = nil;
    if(showHud)
    {
        hud = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:hud];
        //hud.labelText = (imagesCount > 1) ? [NSString stringWithFormat:@"正在上传...剩余%ld张", (long)imagesCount] : @"正在上传...";
        hud.labelText = [NSString stringWithFormat:@"正在上传...剩余%ld张", (long)imagesCount];
        hud.removeFromSuperViewOnHide = YES;
        [hud show:YES];
    }
    
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (customAttr && customValue) {
            [formData appendPartWithFormData:customValue name:customAttr];
        }
        [formData appendPartWithFormData:descdata name:@"description"];
        [formData appendPartWithFileData:data name:@"picUrl" fileName:@"upload.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation,id responseObject) {
        if (imagesCount == 1) {
            if(showHud)
                [hud hide:YES];
            
            if (success != nil) {
                success(operation, responseObject);
            }
        } else {
            //递归上传下一个图片
            [KGUtil uploadImage:curl images:otherImages description:description customAttr:customAttr customValue:customValue success:success failure:failure inView:view showHud:showHud];
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

#pragma mark - push webview
+ (void)pushWebView:(NSString *)webViewType inViewController:(UIViewController*)vc
{
    if(webViewType == nil)
        return;
    
    if(vc == nil)
        return;
    
    NSString *title = @"";
    
    NSString *curl = @"";
    if ([webViewType isEqual:@"bringmedic"]){
        //健康
        curl = @"/health/bringmedic";
    }
    else if([webViewType isEqual:@"givemedic"]){
        //晨检
        curl = @"/health/givemedic";
    }
    else if([webViewType isEqual:@"rollcall"]){
        //点名
        curl = @"/morningCheck/rollcall";
    }
    else if([webViewType isEqual:@"parentsmess"]){
        //家长信箱
        curl = @"/message/parentsmess";
    }
    else if([webViewType isEqual:@"teachermess"]){
        //教师信箱
        curl = @"/message/teachermess";
    }
    else if([webViewType isEqual:@"intopark"]){
        //进园
        curl = @"/morningCheck/intopark";
    }
    else if([webViewType isEqual:@"holidaylist"]){
        //请假处理
        curl = @"/holiday/list";
    }
    else if([webViewType isEqual:@"outpark"]){
        //出园
        curl = @"/morningCheck/outpark";
    }
    else if([webViewType isEqual:@"askholiday"]){
        //请假
        curl = @"/holiday/askto";
    }
    else if([webViewType isEqual:@"bulletin"]){
        //公告
        curl = @"/message/bulletin";
    }
    else if([webViewType isEqual:@"lesson"]){
        //课程表
        curl = @"/book/lesson";
    }
    else if([webViewType isEqual:@"birthday"]){
        //生日提醒
        curl = @"/book/birthday";
    }
    else if([webViewType isEqual:@"cookbook"]){
        //菜谱
        curl = @"/book/cookbook";
    }
    else if([webViewType isEqual:@"masterMess"]){
        //园长信箱
        curl = @"/message/masterMess";
    }
    else if([webViewType isEqual:@"students"]){
        //班级统计
        curl = @"/statistics/students";
    }
    else if([webViewType isEqual:@"feedback"]){
        //反馈
        curl = @"/FeedBack/prefer";
    }
    else {
        return;
    }
    
    //get url
    NSString *uid = [KGUtil getUser].uid;
    NSInteger cid = 0;
    KGChild *child = [KGUtil getCurChild];
    if(child != nil)
        cid = child.cid;
    NSInteger gid = [KGUtil getCurClassId];
    
    NSString *body = nil;
    if(![KGUtil isTeacherVersion])
    {
        body = [NSString stringWithFormat:@"c=%ld&dt=%@&u=%@", (long)cid, [KGUtil getCompactDateStr], uid];
    }
    else
    {
        body = [NSString stringWithFormat:@"dt=%@&g=%ld&u=%@", [KGUtil getCompactDateStr], (long)gid, uid];
    }
    NSString *url = [KGUtil getRequestHtmlUrl:curl bodyStr:body];
    //
    
    WebViewController *webvc = [[WebViewController alloc] init];;
    webvc.title = title;
    webvc.url = url;
    webvc.bgColor = [UIColor colorWithRed:192/255.0 green:218/255.0 blue:216/255.0 alpha:1];
    webvc.hidesBottomBarWhenPushed = true;
    //[KGUtil.getWebVC clearWebView];
    
    [vc.navigationController pushViewController:webvc animated:YES];
}

// 供推送web页面用，每次都new webvc
+ (void)pushWebViewWithUrl:(NSString *)url inViewController:(UIViewController*)vc
{
    if(url == nil || [url length] == 0 )
        return;
    
    if(vc == nil)
        return;
    
    //指示当前webvc保留使用，willdisappear的时候不清空
//    [KGUtil getWebVC].keepUsing = true;
    
    WebViewController *wvc = [[WebViewController alloc] init];
    wvc.url = url;
    wvc.hidesBottomBarWhenPushed = true;
    [vc.navigationController pushViewController:wvc animated:YES];
}

+ (void)pushViewByNotification {
    // 通过点击push message热启动应用，切换push到type页面。由Appdelegate调用
    // 此函数在didReceiveRemoteNotification之后触发，保证能够获取到push数据
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    if(delegate.isLaunchedByNotification)
    {
//        UIViewController *tmVC = [[UIApplication sharedApplication] topMostViewController];
//        if (tmVC == nil) {
//            NSLog(@"pushViewByNotification most vc is nil when");
//        }
//        
//        delegate.isLaunchedByNotification = false;//只切换一次
        if(delegate.curKGVC !=nil && [delegate.curKGVC isKindOfClass:[KGUIViewController class]])
        {
            if(delegate.pushUrl != nil && [delegate.pushUrl length] > 4 && [[delegate.pushUrl substringToIndex:4] isEqual:@"http"])
            {// url push
                [KGUtil pushWebViewWithUrl:delegate.pushUrl inViewController:delegate.curKGVC];
            }
            else if(delegate.pushFunc != nil && [delegate.pushFunc length] > 0)
            {// 暂不启用
                [KGUtil pushWebView:delegate.pushFunc inViewController:delegate.curKGVC];
            }
        }
    }
}

@end
