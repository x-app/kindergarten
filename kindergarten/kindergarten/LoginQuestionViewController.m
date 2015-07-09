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
#import "AFHTTPRequestOperationManager.h"
#import "MLTableAlert.h"
#import "BabyViewController.h"
@interface LoginQuestionViewController ()
@property (weak, nonatomic) IBOutlet UITextField *questionTextField;
@property (weak, nonatomic) IBOutlet UITextField *answerTextField;
@property (strong, nonatomic) MLTableAlert *alert;


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
            //[lockVC dismiss:1.0f];
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            if (mainStoryboard == nil) {
//                NSLog(@"main.storyboard is nil");
//                [lockVC dismiss:0];
//                return;
//            }
            [lockVC dismiss:0];
            [self dismissViewControllerAnimated:YES completion:nil];
            BabyViewController *bvc = [mainStoryboard instantiateInitialViewController];
            bvc.usrRegistered = YES;
            bvc.usrVerified = YES;
            [self presentViewController:bvc animated:NO completion:nil];
        }];
    }
}
- (IBAction)questionFieldTouchDown:(id)sender {
    NSLog(@"request kindergarten list");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *body = @{@"dateTime":@"2015-07-06 08:00:00"};
    NSDictionary *parameters = @{@"uid": @"nugget",@"sign":@"85f5be315df31b1253fe57b82a0882dc",@"body":body};
    //NSString *url = @"http://app.nugget-nj.com/kindergarten_index/queryKindergarten";
    NSString *url = @"http://app.nugget-nj.com/kindergarten_app/system/queryQuestion";
    NSString *strParam = @"{'body':{'dateTime':'2015-07-06 08:00:00'},'uid':'nugget', 'sign':'85f5be315df31b1253fe57b82a0882dc'}";
    NSData *xmlData = [strParam dataUsingEncoding:NSASCIIStringEncoding];
    NSLog(@"%@",xmlData);
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        //        NSData *data  = (NSData *)responseObject;
        //        NSString *rstring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //        NSLog(@"%@",rstring);
        NSArray *parkList = [responseObject objectForKey:@"objlist"];
        
        self.alert = [MLTableAlert tableAlertWithTitle:@"请选择密码保护问题" cancelButtonTitle:nil numberOfRows:^NSInteger(NSInteger section) {
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
        self.alert.height = 350;
        
        // configure actions to perform
        [self.alert configureSelectionBlock:^(NSIndexPath *selectedIndex){
            //self.resultLabel.text = [NSString stringWithFormat:@"Selected Index\nSection: %d Row: %d", selectedIndex.section, selectedIndex.row];
            //NSString *selection = [NSString stringWithFormat:@"Selected Index\nSection: %d Row: %d", selectedIndex.section, selectedIndex.row];
            //NSLog(@"%@", selection);
            NSDictionary *curPark = [parkList objectAtIndex:selectedIndex.row];
            NSString *parkName = [curPark objectForKey:@"parkName"];
            self.questionTextField.text = parkName;
            NSLog(@"hahaha");
        } andCompletionBlock:^{
            NSLog(@"cancelled");
        }];
        
        // show the alert
        [self.alert show];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
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
