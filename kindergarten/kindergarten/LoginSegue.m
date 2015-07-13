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
    [self profileToQuestion];
    LoginViewContoller *current = self.sourceViewController;
    LoginViewContoller *next = self.destinationViewController;
    next.fromVC = current.fromVC;
    [current.navigationController pushViewController:next animated:YES];
    
}

- (void)profileToQuestion {
    NSLog(@"verify user profile");
    LoginViewContoller *current = self.sourceViewController;
    NSDictionary *profile = @{@"name": current.nameTextField.text, @"idNo": current.idNoTextField.text};
    NSDictionary *body = [KGUtil getRequestBody:profile];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    NSString *url = @"http://app.nugget-nj.com/nugget_app/parent/regValid";
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    } inView:current.view];
}

@end
