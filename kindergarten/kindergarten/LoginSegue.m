//
//  LoginSegue.m
//  kindergarten
//
//  Created by 庄小仙 on 15/7/10.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "LoginSegue.h"
#import "LoginViewContoller.h"
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
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            next.fromVC = current.fromVC;
            [current.navigationController pushViewController:next animated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    } inView:current.view];
}

@end
