//
//  LoginViewContoller.h
//  kindergarten
//
//  Created by wangbin on 15/7/11.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewContoller : UIViewController<UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIViewController *fromVC;
@property (strong, nonatomic) UIViewController *nextVC;

@property (weak, nonatomic) IBOutlet UITextField *idNoTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *parkTextField;
@property (weak, nonatomic) IBOutlet UITextField *qstnTextField;
@property (weak, nonatomic) IBOutlet UITextField *nswrTextField;

@end
