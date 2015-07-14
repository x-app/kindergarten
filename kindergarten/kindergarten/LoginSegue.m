//
//  LoginSegue.m
//  kindergarten
//
//  Created by 庄小仙 on 15/7/10.
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
    NSString *url = @"http://app.nugget-nj.com/nugget_app/parent/regValid";
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            if (delegate.user.regMode == 0) {
                UIAlertView *hint = [[UIAlertView alloc] initWithTitle:@"请确认" message:@"用户已经注册,你是否是要找回密码?" delegate:current.self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
                [hint show];
                //[hint release];
                //[KGUtil showAlert:@"刚用户已经注册,你是否是要找回密码?" inView:current.view];
            } else if (delegate.user.regMode == 1) {
                NSDictionary *obj = [responseObject objectForKey:@"obj"];
                delegate.user.question = [obj objectForKey:@"question"];
                delegate.user.parentID = [obj objectForKey:@"parentid"];
                delegate.user.uid = [obj objectForKey:@"iuId"];
                delegate.user.answer = [obj objectForKey:@"answer"];
                next.fromVC = current.fromVC;
                //next.qstnTextField.text = question;
                [current.navigationController pushViewController:next animated:YES];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    } inView:current.view];
}

@end
