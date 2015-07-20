//
//  ClassViewController.m
//  kindergarten
//
//  Created by slice on 15-7-1.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "ClassViewController.h"
#import "KGUtil.h"
#import "KGConst.h"
#import "ChildTableViewController.h"
@interface ClassViewController ()

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *func;
@property (weak, nonatomic) IBOutlet UIImageView *repeatImage;
@property (weak, nonatomic) IBOutlet UILabel *babyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *classNameLabel;

@end

@implementation ClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //设置scrollView背景
    UIImage *backgroundImage = [UIImage imageNamed:@"repeat_img.png"];
    UIColor *backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    [self.repeatImage setBackgroundColor:backgroundColor];
    
    
    for(int i=0; i<[self.func count]; i++)
    {
        UIImageView* v= self.func[i];
        //[(UIControl *)v addTarget:self action:@selector(onImageClick:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageClick:)];
        [v addGestureRecognizer:singleTap1];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    KGChild *curChild = KGUtil.getCurChild;
    if(curChild)
    {
        self.babyNameLabel.text = curChild.name;
        self.classNameLabel.text = [NSString stringWithFormat:@"%@%@", KGUtil.getVarible.parkName, curChild.className];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onImageClick:(UITapGestureRecognizer*) sender{
    //NSLog(@"%ld", (long)sender.view.tag);
    NSInteger tag = sender.view.tag;
    
    UIViewController *vc = nil;
    //    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    
    switch (tag){
        case 1:{
            [self webVC].title = @"公告";
            [self.navigationController pushViewController:[self webVC] animated:YES];
            
            NSString *body = [NSString stringWithFormat:@"c=%@&dt=%@&u=%@", @"2013110", [KGUtil getCompactDateStr], @"20141021172851000015"];
            NSString *url = [KGUtil getRequestHtmlUrl:@"/message/bulletin" bodyStr:body];
            
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [[self webVC].webView loadRequest:request];

            break;
        }
        case 2:{
            [self webVC].title = @"课程表";
            [self.navigationController pushViewController:[self webVC] animated:YES];
            
            NSString *body = [NSString stringWithFormat:@"c=%@&dt=%@&u=%@", @"2013110", [KGUtil getCompactDateStr], @"20141021172851000015"];
            NSString *url = [KGUtil getRequestHtmlUrl:@"/book/lesson" bodyStr:body];
            
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [[self webVC].webView loadRequest:request];
            break;
        }
        case 3:{
            break;
        }
        case 4:{
            [self webVC].title = @"生日提醒";
            [self.navigationController pushViewController:[self webVC] animated:YES];
            
            NSString *body = [NSString stringWithFormat:@"c=%@&dt=%@&u=%@", @"2013110", [KGUtil getCompactDateStr], @"20141021172851000015"];
            NSString *url = [KGUtil getRequestHtmlUrl:@"/book/birthday" bodyStr:body];
            
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [[self webVC].webView loadRequest:request];
            break;
        }
        case 5:{
            break;
        }
        case 6:{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Child" bundle:nil];
            vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChildView"];
            ChildTableViewController *childVC = (ChildTableViewController *)vc;
            if (childVC == nil) {
                break;
            }
            NSDictionary *data = @{@"classID": [[KGUtil getCurChild] classID],
                                   @"pageIndex": @1,
                                   @"pageSize":@10};
            NSDictionary *body = [KGUtil getRequestBody:data];
            NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
            NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:@"/system/pageQueryHomework"];
            [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                NSString *code = [responseObject objectForKey:@"code"];
                if ([code isEqualToString:@"000000"]) {
                    NSArray *homeworkArray = (NSArray *)[responseObject objectForKey:@"objlist"];
                    childVC.homeworks = [[NSMutableArray alloc] initWithCapacity:[homeworkArray count]];
                    for (int i = 0; i < [homeworkArray count]; i++) {
                        NSDictionary *hwDict = [homeworkArray objectAtIndex:i];
                        KGHomework *homework = [[KGHomework alloc] initWithDesc:[hwDict objectForKey:@"description"]
                                                                        classId:[[hwDict objectForKey:@"classId"] integerValue]
                                                                     homeworkId:[[hwDict objectForKey:@"homeworkId"] integerValue]
                                                                         picUrl:[hwDict objectForKey:@"picUrl"]
                                                                    smallPicUrl:[hwDict objectForKey:@"smallPicUrl"]
                                                                       createAt:[hwDict objectForKey:@"createTime"]];
                        [childVC.homeworks addObject:homework];
                    }
                    [self.navigationController pushViewController:childVC animated:YES];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            } inView:childVC.tableView];
            break;
        }
        default:
            break;
    }
    
}


@end
