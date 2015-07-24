//
//  MeViewController.m
//  kindergarten
//
//  Created by slice on 15-7-5.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "MeViewController.h"
#import "AppDelegate.h"
#import "MeFunction.h"
#import "CLLockVC.h"
#import "KGUtil.h"

@interface MeViewController ()

@property (strong, nonatomic) NSArray *functions;

@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.funcTableView.delegate = self;
    self.funcTableView.dataSource = self;
    [self initFunctionData];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initFunctionData {
    MeFunction *changePswd = [[MeFunction alloc] init];
    changePswd.type = CHANGE_PSWD;
    changePswd.title = @"修改密码";
    changePswd.cellId = @"changePswdCell";
    changePswd.icon = @"password_icon.png";
    
    MeFunction *settings = [[MeFunction alloc] init];
    settings.type = SETTINGS;
    settings.title = @"清除缓存";
    settings.cellId = @"clearCacheCell";
    settings.icon = @"setting_icon.png";
    
    MeFunction *feedback = [[MeFunction alloc] init];
    feedback.type = FEEDBACK;
    feedback.title = @"反馈建议";
    feedback.cellId = @"feedbackCell";
    feedback.icon = @"feedback_icon.png";
    
    MeFunction *about = [[MeFunction alloc] init];
    about.type = ABOUT;
    about.title = @"关于";
    about.cellId = @"aboutCell";
    about.icon = @"about_icon.png";
    
    self.functions = @[changePswd, settings, feedback, about];
    [self.funcTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    if (delegate != nil && delegate.user != nil && delegate.user.name != nil) {
//        self.userLabel.text = [NSString stringWithFormat:@"尊敬的%@, 您好！", delegate.user.name];
//    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.funcTableView deselectRowAtIndexPath:[self.funcTableView indexPathForSelectedRow] animated:NO];
}

#pragma TableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.functions count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"尊敬的黄晓伟用户, 您好！";
}


-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return @"";
}

#pragma TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSString *cellId = [NSString stringWithFormat:@"funcCell%ld", indexPath.row];
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"" forIndexPath:indexPath];
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    MeFunction *curFunc = (MeFunction *)[self.functions objectAtIndex:indexPath.row];
    if (curFunc != nil) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:curFunc.cellId forIndexPath:indexPath];
        cell.textLabel.text = curFunc.title;
//        cell.textLabel.text = curFunc.title;
//        UIImage *iconImg = [UIImage imageNamed:curFunc.icon];
//        cell.imageView.image = iconImg;
        return cell;
    } else {
        return nil;
    }
}
//

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.font = [UIFont systemFontOfSize:15];// = [UIFont boldSystemFontOfSize:16];
    headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
    headerLabel.text = @"尊敬的黄晓伟用户, 您好！";
    
    [customView addSubview:headerLabel];
    
    return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}


//
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [self.functions count] || indexPath.row < 0) {
        return;
    }
    MeFunction *curFunc = [self.functions objectAtIndex:indexPath.row];
    switch (curFunc.type) {
        case CHANGE_PSWD: {
            BOOL hasPwd = [CLLockVC hasPwd];
            if(!hasPwd) {
                NSLog(@"你还没有设置密码，请先设置密码");
                
            } else {
                [CLLockVC showModifyLockVCInVC:self successBlock:^(CLLockVC *lockVC, NSString *pwd) {
                    [lockVC dismiss:.5f];
                }];
            }
            break;
        }
            
        case FEEDBACK: {
            [self webVC].title = @"意见反馈";
            [self.navigationController pushViewController:[self webVC] animated:YES];
            
            NSString *body = [NSString stringWithFormat:@"c=%@&dt=%@&u=%@", @"2013110", [KGUtil getCompactDateStr], @"20141021172851000015"];
            NSString *url = [KGUtil getRequestHtmlUrl:@"/FeedBack/prefer" bodyStr:body];
            
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [[self webVC].webView loadRequest:request];
            break;
        }
            
        case ABOUT: {
            //[self performSegueWithIdentifier:@"aboutSegue" sender:self];
            break;
        }
            
        default:
            break;
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
