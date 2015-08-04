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
#import "AFHTTPRequestOperationManager.h"
#import "MLTableAlert.h"
#import "KGUtil.h"
#import "KGConst.h"
#import "KGChild.h"
#import "KGClass.h"
@interface LoginViewContoller ()


@property (strong, nonatomic) NSArray *parkList;
@property (strong, nonatomic) NSArray *qstnList;
@property (strong, nonatomic) MLTableAlert *tableAlert;

@end

@implementation LoginViewContoller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.parkTextField setupTextFieldWithIconName:@"user_name_icon.png"];
    [self.idNoTextField setupTextFieldWithIconName:@"as_password_icon.png"];
    [self.nameTextField setupTextFieldWithIconName:@"user_name_icon.png"];
    [self.qstnTextField setupTextFieldWithIconName:@"as_password_icon.png"];
    [self.nswrTextField setupTextFieldWithIconName:@"user_name_icon.png"];
    self.parkTextField.delegate = self;
    self.qstnTextField.delegate = self;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleToFill;
    [imageView setImage:[UIImage imageNamed:@"bg_11.png"]];
    [self.view insertSubview:imageView atIndex: 0];
    NSLog(@"LoginViewController did load");
}

- (void)viewDidAppear:(BOOL)animated {
    AppDelegate* delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate.user.regMode == 1) {
        if (![delegate.user.question isEqualToString:@""]) {
            self.qstnTextField.text = delegate.user.question;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)finishQuestionAction:(UIButton *)sender {
    if ([self.nswrTextField.text isEqualToString:@""]) {
        [KGUtil showAlert:@"请填写密保问题答案" inView:self.view];
        return;
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate.user.regMode == 1) {
        NSString *inputAnswer = self.nswrTextField.text;
        NSString *md5Answer = [KGUtil getMD5Str:inputAnswer];
        if (![delegate.user.answer isEqualToString:md5Answer]) {
            [KGUtil showAlert:@"答案错误" inView:self.view];
            return;
        }
        [self setGesturePswd];
    } else {
        delegate.user.answer = self.nswrTextField.text;
        NSDictionary *profile = @{@"name": delegate.user.name,
                                  @"idNo": delegate.user.idNo,
                                  @"questionId":@(delegate.user.questionID),
                                  @"answer":delegate.user.answer,
                                  @"pwd":@"123456",
                                  @"deviceId":@""};
        NSDictionary *body = [KGUtil getRequestBody:profile];
        NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
        //NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
        NSString *urlSuffix = [KGUtil isTeacherVersion] ? @"/teacher/register" : @"/parent/register";
        NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:urlSuffix];
        [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            NSString *code = [responseObject objectForKey:@"code"];
            if ([code isEqualToString:@"000000"]) {
                NSDictionary *obj = [responseObject objectForKey:@"obj"];
                delegate.user.uid = [obj objectForKey:@"iuid"];
                if ([KGUtil isTeacherVersion]) {
                    delegate.user.teacherID = [(NSString *)[obj objectForKey:@"teacherid"] integerValue];
                } else {
                    delegate.user.parentID = [(NSString *)[obj objectForKey:@"parentid"] integerValue];
                }
                [self setGesturePswd];
                //下面开始查询幼儿信息
//                NSString *childUrl = [[KGUtil getServerAppURL] stringByAppendingString:@"parent/queryChildInfo"];
//                NSDictionary *data = @{@"iuid": delegate.user.uid};
//                NSDictionary *childBody = [KGUtil getRequestBody:data];
//                NSDictionary *childParams = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:childBody], @"body": body};
//                [KGUtil postRequest:childUrl parameters:childParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                    NSLog(@"JSON: %@", responseObject);
//                    [self setGesturePswd];
//                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                    //查询幼儿失败
//                } inView:self.view];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        } inView:self.view
         showHud:true
         showError:true];
    }
}
/**
 *  在注册阶段家长查询幼儿信息
 *
 *  @param uid 用户uid
 */
- (void)queryChildInfo: (NSString *)uid {
    //下面开始查询幼儿信息
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:@"/parent/queryChildInfo"];
    NSDictionary *data = @{@"iuId": uid};
    NSDictionary *body = [KGUtil getRequestBody:data];
    NSDictionary *childParams = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body": body};
    [KGUtil postRequest:url parameters:childParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            NSArray *childs = [responseObject objectForKey:@"objlist"];
            if ([childs count] == 0) {
                //没有幼儿信息
                [KGUtil showAlert:@"未查询到宝宝信息" inView:self.view];
            } else {
                [delegate.user.childs removeAllObjects];
                
                for (int i = 0; i < [childs count]; i++) {
                    //..
                    
                    NSDictionary *childInfo = (NSDictionary *)[childs objectAtIndex:i];
                    KGChild *child = [[KGChild alloc] initWithName:[childInfo objectForKey:@"name"]
                                                                id:[[childInfo objectForKey:@"id"] integerValue]
                                                               sex:[[childInfo objectForKey:@"sex"] integerValue]
                                                           classID:[[childInfo objectForKey:@"classId"] integerValue]
                                                         className:[childInfo objectForKey:@"className"]
                                                          birthday:[childInfo objectForKey:@"birthday"]];
                    [delegate.user.childs addObject:child];
                }
                delegate.user.curChild = [delegate.user.childs objectAtIndex:0];
                if(childs.count > 0){
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:childs forKey:@"curchilds"];
                }
                [self.navigationController pushViewController:self.nextVC animated:YES];
            }
        } else {
            //失败
        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //查询幼儿失败
    } inView:self.view
     showHud:true
   showError:true];
}

/**
 *  注册阶段教师查询班级信息
 *
 *  @param uid 用户uid
 */
- (void)queryClassInfo: (NSString *)uid {
    //下面开始查询幼儿信息
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:@"/teacher/queryClassInfo"];
    NSDictionary *data = @{@"iuId": uid};
    NSDictionary *body = [KGUtil getRequestBody:data];
    NSDictionary *childParams = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body": body};
    [KGUtil postRequest:url
             parameters:childParams
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    NSString *code = [responseObject objectForKey:@"code"];
                    if ([code isEqualToString:@"000000"]) {
                        NSArray *classes = [responseObject objectForKey:@"objlist"];
                        if ([classes count] == 0) {
                            //没有班级信息
                            [KGUtil showAlert:@"未查询到班级信息" inView:self.view];
                        } else {
                            [delegate.user.classes removeAllObjects];
                            
                            for (int i = 0; i < [classes count]; i++) {
                                //..
                                NSDictionary *classInfo = (NSDictionary *)[classes objectAtIndex:i];
                                KGClass *curClass = [[KGClass alloc] initWithName:[classInfo objectForKey:@"className"]
                                                                          classId:[[classInfo objectForKey:@"classId"] integerValue]];
                                [delegate.user.classes addObject:curClass];
                            }
                            //delegate.user.curChild = [delegate.user.childs objectAtIndex:0];
                            if (classes.count > 0){
                                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                [userDefaults setObject:classes forKey:@"curclasses"];
                            }
                            [self.navigationController pushViewController:self.nextVC animated:YES];
                        }
                    } else {
                        //失败
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    //查询班级失败
                }
                 inView:self.view
                showHud:true
              showError:true];
}

- (void)setGesturePswd {
    BOOL hasPwd = [CLLockVC hasPwd];
    hasPwd = NO;
    if(hasPwd) {
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
            [lockVC dismissViewControllerAnimated:NO completion:^(void) {
                delegate.user.registered = YES;
                delegate.user.verified = YES;
                delegate.user.registering = NO;
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
- (IBAction)parkTextFieldTouchDown:(UITextField *)sender {
    if (self.parkList != nil && [self.parkList count] > 0) {
        [self showParkList];
        return;
    }
    NSLog(@"request kindergarten list");
    NSDictionary *body = [KGUtil getRequestBody:@{}];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    NSString *url = [[KGUtil getServerIndexURL] stringByAppendingString:@"/queryKindergarten"];
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSArray *parkList = [responseObject objectForKey:@"objlist"];
        self.parkList = parkList;
        [self showParkList];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    } inView:self.view
     showHud:true
     showError:true];
}

- (void)showParkList {
    if ([self.parkList count] == 0) {
        [self.parkTextField resignFirstResponder];
        return;
    }
    self.tableAlert = nil;
    self.tableAlert = [MLTableAlert tableAlertWithTitle:@"请选择注册的幼儿园" cancelButtonTitle:nil numberOfRows:^NSInteger(NSInteger section) {
        return [self.parkList count];
    } andCells:^UITableViewCell *(MLTableAlert *alert, NSIndexPath *indexPath) {
        static NSString *CellIdentifier = @"CellIdentifier";
        UITableViewCell *cell = [alert.table dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        NSDictionary *curPark = [self.parkList objectAtIndex:indexPath.row];
        NSString *parkName = [curPark objectForKey:@"parkName"];
        
        cell.textLabel.text = parkName;
        return cell;
    }];
    
    
    // Setting custom alert height
    self.tableAlert.height = 350;
    
    // configure actions to perform
    [self.tableAlert configureSelectionBlock:^(NSIndexPath *selectedIndex){
        NSDictionary *curPark = [self.parkList objectAtIndex:selectedIndex.row];
        NSString *parkName = [curPark objectForKey:@"parkName"];
        NSString *appUrl = [curPark objectForKey:@"appUrl"];
        NSString *htmlUrl = [curPark objectForKey:@"appHtmlUrl"];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.varible.server_app_url = appUrl;
        delegate.varible.server_html_url = htmlUrl;
        delegate.varible.parkName = parkName;
        [[NSUserDefaults standardUserDefaults] setObject:[delegate.varible toDictionary] forKey:@"varible"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.parkTextField.text = parkName;
        [self.parkTextField resignFirstResponder];
    } andCompletionBlock:^{
        NSLog(@"cancelled");
    }];
    
    // show the alert
    [self.tableAlert show];
}


- (void)showQstnList {
    if ([self.qstnList count] == 0) {
        [self.qstnTextField resignFirstResponder];
        return;
    }
    self.tableAlert = nil;
    self.tableAlert = [MLTableAlert tableAlertWithTitle:@"请选择密保问题" cancelButtonTitle:nil numberOfRows:^NSInteger(NSInteger section) {
        return [self.qstnList count];
    } andCells:^UITableViewCell *(MLTableAlert *alert, NSIndexPath *indexPath) {
        static NSString *CellIdentifier = @"CellIdentifier";
        UITableViewCell *cell = [alert.table dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        NSDictionary *curQuestion = [self.qstnList objectAtIndex:indexPath.row];
        NSString *question = [curQuestion objectForKey:@"question"];
        
        cell.textLabel.text = question;
        return cell;
    }];
    
    
    // Setting custom alert height
    self.tableAlert.height = 350;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // configure actions to perform
    [self.tableAlert configureSelectionBlock:^(NSIndexPath *selectedIndex){
        NSDictionary *curQuestion = [self.qstnList objectAtIndex:selectedIndex.row];
        NSString *question = [curQuestion objectForKey:@"question"];
        NSString *questionID = [curQuestion objectForKey:@"questionId"];
        delegate.user.question = question;
        delegate.user.questionID = [questionID integerValue];
        self.qstnTextField.text = question;
        [self.qstnTextField resignFirstResponder];
    } andCompletionBlock:^{
        NSLog(@"cancelled");
    }];
    
    // show the alert
    [self.tableAlert show];
}
- (IBAction)qstnTextFieldTouchDown:(UITextField *)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate.user.regMode == 1 && ![delegate.user.question isEqualToString:@""]) {
        [self.qstnTextField resignFirstResponder];
        return;
    }
    if (self.qstnList != nil && [self.qstnList count] > 0) {
        [self showQstnList];
        return;
    }
    NSLog(@"request question list");
    NSDictionary *body = [KGUtil getRequestBody:@{}];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    //NSDictionary *body = @{@"dateTime":@"2015-07-13 23:22:46"};
    //NSString *signp = KGUtil getMD5Str:<#(NSString *)#>
    //NSString *re = [KGUtil getRequestSign:body];
    //NSLog(@"%@",re);
    //NSDictionary *params = @{@"uid":@"nugget",@"sign":@"18eda6be778fbd7d09442830685db1b4",@"body":body};
    //NSString *url = @"http://app.nugget-nj.com/nugget_app/system/queryQuestion";
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:@"/system/queryQuestion"];
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSArray *qstnList = [responseObject objectForKey:@"objlist"];
        self.qstnList = qstnList;
        [self showQstnList];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    } inView:self.view
     showHud:true
     showError:true];
}

#pragma mark -- Test Actions --

- (IBAction)test:(UIButton *)sender {
    self.nameTextField.text = @"左玲玲";
    self.idNoTextField.text = @"430421198608170228";
    self.parkTextField.text = @"江苏南京市南戈特幼儿园";
}

- (IBAction)setFakeProfile:(UIButton *)sender {
    self.nameTextField.text = @"黄晓伟";
    self.idNoTextField.text = @"350582197903050273";
    self.parkTextField.text = @"江苏南京市南戈特幼儿园";
}
- (IBAction)jumpToMain:(UIButton *)sender {
    /*AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.user.verified = YES;
    //delegate.user.registering = NO;
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];*/
    self.nameTextField.text = @"许阿密";
    self.idNoTextField.text = @"350582199303073606";
    self.parkTextField.text = @"江苏南京市南戈特幼儿园";
}


#pragma mark -- UIAlertViewDelegate --
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"click alert view");
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (buttonIndex == 0) { //确定-直接进入忘记密码的模式
        delegate.user.regMode = 1;
        if ([KGUtil isTeacherVersion]) {
            [self queryClassInfo: delegate.user.uid];
        } else {
            [self queryChildInfo:delegate.user.uid];
        }
        //[self.navigationController pushViewController:self.nextVC animated:YES];
    } else { //取消-返回main.storyboard
        delegate.user.registering = NO;
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [KGUtil lockTopMostVC];
        }];
    }
}
#pragma mark -- UITextFieldDelegate --
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    //do somthing
    NSLog(@"block text field begin editing");
    return NO;
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
