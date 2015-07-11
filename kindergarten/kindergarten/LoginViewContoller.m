//
//  LoginViewContoller.m
//  kindergarten
//
//  Created by wangbin on 15/7/11.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "LoginViewContoller.h"
#import "ASTextField.h"
#import "CLLockVC.h"
#import "AppDelegate.h"
@interface LoginViewContoller ()

@property (weak, nonatomic) IBOutlet UITextField *idNoTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *parkTextField;
@property (weak, nonatomic) IBOutlet UITextField *qstnTextField;
@property (weak, nonatomic) IBOutlet UITextField *nswrTextField;

@end

@implementation LoginViewContoller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.parkTextField setupTextFieldWithIconName:@"user_name_icon.png"];
    [self.idNoTextField setupTextFieldWithIconName:@"password_icon"];
    [self.nameTextField setupTextFieldWithIconName:@"user_name_icon.png"];
    [self.qstnTextField setupTextFieldWithIconName:@"password_icon"];
    [self.nswrTextField setupTextFieldWithIconName:@"user_name_icon.png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleToFill;
    [imageView setImage:[UIImage imageNamed:@"bg_11.png"]];
    [self.view insertSubview:imageView atIndex: 0];
    NSLog(@"LoginViewController did load");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)finishQuestionAction:(UIButton *)sender {
    [self setGesturePswd];
}

- (void)setGesturePswd {
    BOOL hasPwd = [CLLockVC hasPwd];
    hasPwd = NO;
    if(hasPwd){
        NSLog(@"已经设置过密码了，可以验证或者修改密码");
    } else {
        [CLLockVC showSettingLockVCInVC:self successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            NSLog(@"密码设置成功");
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            //UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            //            if (mainStoryboard == nil) {
            //                NSLog(@"main.storyboard is nil");
            //                [lockVC dismiss:0];
            //                return;
            //            }
            //[self dismissViewControllerAnimated:YES completion:nil];
            //[lockVC dismiss:0];
            [lockVC dismissViewControllerAnimated:YES completion:^(void) {
                delegate.user.registered = YES;
                delegate.user.verified = YES;
                delegate.user.registering = NO;
                [self.navigationController dismissViewControllerAnimated:NO completion:nil];
            }];
            
            if (self.fromVC != nil) {
                NSLog(@"return to fromVC");
                //[self dismissViewControllerAnimated:NO completion:nil];
                //[self presentViewController:self.fromVC animated:YES completion:nil];
            }
            
            //BabyViewController *bvc = [mainStoryboard instantiateInitialViewController];
            //[self presentViewController:bvc animated:NO completion:nil];
            
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
