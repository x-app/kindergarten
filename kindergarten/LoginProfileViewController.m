//
//  LoginViewController.m
//  kindergarten
//
//  Created by slice on 15-7-5.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "LoginProfileViewController.h"
#import "CLLockVC.h"
#import "ASTextField.h"
#import "AFHTTPRequestOperationManager.h"
#import "MLTableAlert.h"
#import "KGUtil.h"

@interface LoginProfileViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *kgTextField;
@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (strong, nonatomic) MLTableAlert *alert;

@property (strong, nonatomic) NSArray *parkList;
@property (nonatomic) NSInteger viewAppearCount;
@end

@implementation LoginProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置三个文本框
    [self.kgTextField setupTextFieldWithIconName:@"user_name_icon.png"];
    [self.idTextField setupTextFieldWithIconName:@"id_card_icon.png"];
    [self.nameTextField setupTextFieldWithIconName:@"user_name_icon.png"];
    //设置背景
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleToFill;
    [imageView setImage:[UIImage imageNamed:@"bg_11.png"]];
    [self.view insertSubview:imageView atIndex: 0];
    NSLog(@"LoginProfileViewController did load");
    
    //[self.view addSubview:imageView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"AAAAA");
    NSLog(@"%@", segue.identifier);
    if ([segue.identifier isEqualToString:@"profile2question"]) {
        NSLog(@"profile-->question");
    }
}

- (IBAction)kgFieldTouchDown:(id)sender {
    NSLog(@"request kindergarten list");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *body = @{@"dateTime":@"2015-07-06 08:00:00"};
    NSDictionary *parameters = @{@"uid": @"nugget",@"sign":@"85f5be315df31b1253fe57b82a0882dc",@"body":body};
    NSString *url = @"http://app.nugget-nj.com/kindergarten_index/queryKindergarten";
    //NSString *url = @"http://app.nugget-nj.com/kindergarten_app/system/queryQuestion";
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
        self.parkList = parkList;
        
        self.alert = [MLTableAlert tableAlertWithTitle:@"请选择注册的幼儿园" cancelButtonTitle:nil numberOfRows:^NSInteger(NSInteger section) {
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
            self.kgTextField.text = parkName;
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

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"LoginProfileViewController did appear");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item {
    return false;
}


- (IBAction)test:(id)sender {
    [KGUtil showAlert:@"test" inView:self.view];
    NSLog(@"login did finish");
}

@end
