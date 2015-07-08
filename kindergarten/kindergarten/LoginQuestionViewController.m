//
//  LoginQuestionViewController.m
//  kindergarten
//
//  Created by 庄小仙 on 15/7/7.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "LoginQuestionViewController.h"
#import "ASTextField.h"
#import "CLLockVC.h"
@interface LoginQuestionViewController ()
@property (weak, nonatomic) IBOutlet UITextField *questionTextField;
@property (weak, nonatomic) IBOutlet UITextField *answerTextField;

@end

@implementation LoginQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置两个文本框
    [self.questionTextField setupTextFieldWithIconName:@"user_name_icon.png"];
    [self.answerTextField setupTextFieldWithIconName:@"id_card_icon.png"];
    //设置背景
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleToFill;
    [imageView setImage:[UIImage imageNamed:@"bg_11.png"]];
    [self.view insertSubview:imageView atIndex: 0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)setGesturePswd:(UIButton *)sender {
    BOOL hasPwd = [CLLockVC hasPwd];
    hasPwd = NO;
    if(hasPwd){
        NSLog(@"已经设置过密码了，你可以验证或者修改密码");
    }else{
        [CLLockVC showSettingLockVCInVC:self successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            NSLog(@"密码设置成功");
            [lockVC dismiss:1.0f];
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
