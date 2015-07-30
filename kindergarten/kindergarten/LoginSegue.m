//
//  LoginSegue.m
//  kindergarten
//
//  Created by wangbin on 15/7/10.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "LoginSegue.h"
#import "LoginViewContoller.h"
#import "AppDelegate.h"
#import "KGUtil.h"
#import "KGConst.h"
@implementation LoginSegue

- (void)perform
{
    //[self profileToQuestion];
    NSLog(@"verify user profile");
    LoginViewContoller *current = self.sourceViewController;
    LoginViewContoller *next = self.destinationViewController;
    if ([current.idNoTextField.text isEqualToString:@""]) {
        [KGUtil showAlert:@"身份证号不能为空" inView:current.view];
        return;
    }
    if ([current.nameTextField.text isEqualToString:@""]) {
        [KGUtil showAlert:@"姓名不能为空" inView:current.view];
        return;
    }
    NSDictionary *profile = @{@"name": current.nameTextField.text, @"idNo": current.idNoTextField.text};
    NSDictionary *body = [KGUtil getRequestBody:profile];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    //NSString *url = @"http://app.nugget-nj.com/nugget_app/parent/regValid";
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:@"/parent/regValid"];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            NSDictionary *obj = [responseObject objectForKey:@"obj"];
            delegate.user.category = [(NSString *)[obj objectForKey:@"category"] integerValue];
            delegate.user.name = [obj objectForKey:@"name"];
            delegate.user.idNo = [obj objectForKey:@"idNo"];
            delegate.user.question = [obj objectForKey:@"question"];
            delegate.user.parentID = [[obj objectForKey:@"parentid"] integerValue];
            delegate.user.uid = [obj objectForKey:@"iuId"];
            delegate.user.answer = [obj objectForKey:@"answer"];
            
            [self saveUser:delegate.user];
            
            next.fromVC = current.fromVC;
            current.nextVC = next;
            if (delegate.user.regMode == 0) {
                if (![delegate.user.question isEqualToString:@""]) { //用户的密保问题不为空, 说明已经注册过了
                    UIAlertView *hint = [[UIAlertView alloc] initWithTitle:@"请确认" message:@"当前用户已经注册,你是否是要找回密码?" delegate:current.self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
                    //current.nextVC = next;
                    [hint show];
                } else {
                    [current queryChildInfo: delegate.user.uid];
                    //[current.navigationController pushViewController:next animated:YES];
                }
                //[hint release];
                //[KGUtil showAlert:@"刚用户已经注册,你是否是要找回密码?" inView:current.view];
            } else if (delegate.user.regMode == 1) {
                [current queryChildInfo: delegate.user.uid];
                //next.qstnTextField.text = question;
                //[current.navigationController pushViewController:next animated:YES];
            }
        } else {
            [KGUtil showAlert:@"验证不通过, 请确保您的信息已注册" inView:current.self.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    } inView:current.view
     showHud:true];
}

-(void)saveUser:(KGUser *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[user toDictionary]  forKey:@"User"];
}

@end
