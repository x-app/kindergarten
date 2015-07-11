//
//  LoginSegue.m
//  kindergarten
//
//  Created by 庄小仙 on 15/7/10.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "LoginSegue.h"
#import "LoginViewContoller.h"
@implementation LoginSegue

- (void)perform
{
    
    LoginViewContoller *current = self.sourceViewController;
    LoginViewContoller *next = self.destinationViewController;
    next.fromVC = current.fromVC;
    [current.navigationController pushViewController:next animated:YES];
    
}

@end
