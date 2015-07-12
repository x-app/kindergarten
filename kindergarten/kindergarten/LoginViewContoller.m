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
@interface LoginViewContoller ()

@property (weak, nonatomic) IBOutlet UITextField *idNoTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *parkTextField;
@property (weak, nonatomic) IBOutlet UITextField *qstnTextField;
@property (weak, nonatomic) IBOutlet UITextField *nswrTextField;

@property (strong, nonatomic) NSArray *parkList;
@property (strong, nonatomic) MLTableAlert *tableAlert;

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
    NSDate *curDate = [[NSDate alloc] init];
    NSDictionary *body = [KGUtil getRequestBody:curDate];
    NSDictionary *params = @{@"uid": REQUEST_UID,@"sign": [KGUtil getRequestSign:curDate], @"body":body};
    NSString *url = @"http://app.nugget-nj.com/kindergarten_index/queryKindergarten";
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        //        NSData *data  = (NSData *)responseObject;
        //        NSString *rstring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //        NSLog(@"%@",rstring);
        NSArray *parkList = [responseObject objectForKey:@"objlist"];
        self.parkList = parkList;
        [self showParkList];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    } inView:self.view];
   /*
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        //        NSData *data  = (NSData *)responseObject;
        //        NSString *rstring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //        NSLog(@"%@",rstring);
        NSArray *parkList = [responseObject objectForKey:@"objlist"];
        self.parkList = parkList;
        
        self.tableAlert = [MLTableAlert tableAlertWithTitle:@"请选择注册的幼儿园" cancelButtonTitle:nil numberOfRows:^NSInteger(NSInteger section) {
            return [parkList count];
        } andCells:^UITableViewCell *(MLTableAlert *alert, NSIndexPath *indexPath) {
            static NSString *CellIdentifier = @"CellIdentifier";
            UITableViewCell *cell = [alert.table dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            NSDictionary *curPark = [parkList objectAtIndex:indexPath.row];
            NSString *parkName = [curPark objectForKey:@"parkName"];
            
            cell.textLabel.text = parkName;
            return cell;
        }];
        
        
        // Setting custom alert height
        self.tableAlert.height = 350;
        
        // configure actions to perform
        [self.tableAlert configureSelectionBlock:^(NSIndexPath *selectedIndex){
            //self.resultLabel.text = [NSString stringWithFormat:@"Selected Index\nSection: %d Row: %d", selectedIndex.section, selectedIndex.row];
            //NSString *selection = [NSString stringWithFormat:@"Selected Index\nSection: %d Row: %d", selectedIndex.section, selectedIndex.row];
            //NSLog(@"%@", selection);
            NSDictionary *curPark = [parkList objectAtIndex:selectedIndex.row];
            NSString *parkName = [curPark objectForKey:@"parkName"];
            self.parkTextField.text = parkName;
            [self.parkTextField resignFirstResponder];
            NSLog(@"hahaha");
        } andCompletionBlock:^{
            NSLog(@"cancelled");
        }];
        
        // show the alert
        [self.tableAlert show];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];*/
}

- (void)showParkList {
    //[self.tableAlert dealloc];
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
        //self.resultLabel.text = [NSString stringWithFormat:@"Selected Index\nSection: %d Row: %d", selectedIndex.section, selectedIndex.row];
        //NSString *selection = [NSString stringWithFormat:@"Selected Index\nSection: %d Row: %d", selectedIndex.section, selectedIndex.row];
        //NSLog(@"%@", selection);
        NSDictionary *curPark = [self.parkList objectAtIndex:selectedIndex.row];
        NSString *parkName = [curPark objectForKey:@"parkName"];
        self.parkTextField.text = parkName;
        [self.parkTextField resignFirstResponder];
        NSLog(@"hahaha");
    } andCompletionBlock:^{
        NSLog(@"cancelled");
    }];
    
    // show the alert
    [self.tableAlert show];
}

- (IBAction)qstnTextFieldTouchDown:(UITextField *)sender {
}
- (IBAction)test:(UIButton *)sender {
    //[KGUtil showAlert:@"hehehe" inView:self.view];
    [KGUtil showLoading:self.view];
}
- (IBAction)setFakeProfile:(UIButton *)sender {
    self.nameTextField.text = @"黄晓伟";
    self.idNoTextField.text = @"350582197903050273";
}
- (IBAction)jumpToMain:(UIButton *)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.user.verified = YES;
    //delegate.user.registering = NO;
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
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
