//
//  ClassViewController.m
//  kindergarten
//
//  Created by slice on 15-7-1.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "ClassViewController.h"
#import "KGUtil.h"
#import "ChildTableViewController.h"
#import "IntroductionViewController.h"
@interface ClassViewController ()

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *func;
@property (weak, nonatomic) IBOutlet UIImageView *repeatImage;
//@property (weak, nonatomic) IBOutlet UILabel *babyNameLabel;
//@property (weak, nonatomic) IBOutlet UILabel *classNameLabel;

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
    
//    KGChild *curChild = KGUtil.getCurChild;
//    if(curChild)
//    {
//        self.babyNameLabel.text = curChild.name;
//        self.classNameLabel.text = [NSString stringWithFormat:@"%@%@", KGUtil.getVarible.parkName, curChild.className];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onImageClick:(UITapGestureRecognizer*) sender{
    //NSLog(@"%ld", (long)sender.view.tag);
    NSInteger tag = sender.view.tag;
    
    UIViewController *vc = nil;

    NSString *uid = [KGUtil getUser].uid;
    NSInteger cid = 0;
    KGChild *child = [KGUtil getCurChild];
    if(child != nil)
        cid = child.cid;
    NSInteger gid = [KGUtil getCurClassId];

    NSString *url = nil;
    switch (tag){
        case 1:{
            [self webVC].title = @"公告";
            [self.navigationController pushViewController:[self webVC] animated:YES];
            
            if(![KGUtil isTeacherVersion])
            {
                NSString *body = [NSString stringWithFormat:@"c=%ld&dt=%@&u=%@", (long)cid, [KGUtil getCompactDateStr], uid];
                url = [KGUtil getRequestHtmlUrl:@"/message/bulletin" bodyStr:body];
            }
            else
            {
                NSString *body = [NSString stringWithFormat:@"dt=%@&g=%ld&u=%@", [KGUtil getCompactDateStr], (long)gid, uid];
                url = [KGUtil getRequestHtmlUrl:@"/message/bulletin" bodyStr:body];
            }
            
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [[self webVC].webView loadRequest:request];

            break;
        }
        case 2:{
            [self webVC].title = @"课程表";
            [self.navigationController pushViewController:[self webVC] animated:YES];
            
            if(![KGUtil isTeacherVersion])
            {
                NSString *body = [NSString stringWithFormat:@"c=%ld&dt=%@&u=%@", (long)cid, [KGUtil getCompactDateStr], uid];
                url = [KGUtil getRequestHtmlUrl:@"/book/lesson" bodyStr:body];
            }
            else
            {
                NSString *body = [NSString stringWithFormat:@"dt=%@&g=%ld&u=%@", [KGUtil getCompactDateStr], (long)gid, uid];
                url = [KGUtil getRequestHtmlUrl:@"/book/lesson" bodyStr:body];
            }
            
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [[self webVC].webView loadRequest:request];
            break;
        }
        case 3:{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Introduction" bundle:nil];
            UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"IntroductionView"];
            IntroductionViewController *ivc = (IntroductionViewController *)vc;
            if (ivc != nil) {
                ivc.type = CLASS;
                [self.navigationController pushViewController:ivc animated:YES];
            }
            break;
        }
        case 4:{
            [self webVC].title = @"生日提醒";
            [self.navigationController pushViewController:[self webVC] animated:YES];
            
            if(![KGUtil isTeacherVersion])
            {
                NSString *body = [NSString stringWithFormat:@"c=%ld&dt=%@&u=%@", (long)cid, [KGUtil getCompactDateStr], uid];
                url = [KGUtil getRequestHtmlUrl:@"/book/birthday" bodyStr:body];
            }
            else
            {
                NSString *body = [NSString stringWithFormat:@"dt=%@&g=%ld&u=%@", [KGUtil getCompactDateStr], (long)gid, uid];
                url = [KGUtil getRequestHtmlUrl:@"/book/birthday" bodyStr:body];

            }
            
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [[self webVC].webView loadRequest:request];
            break;
        }
        case 5:{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Album" bundle:nil];
            vc = [storyBoard instantiateViewControllerWithIdentifier:@"ActivityAlbum"];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 6:{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Child" bundle:nil];
            vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChildView"];
            ChildTableViewController *cvc = (ChildTableViewController *)vc;
            if (cvc != nil) {
                cvc.type = HOMEWORK;
                [self.navigationController pushViewController:cvc animated:YES];
            }
            break;
        }
        default:
            break;
    }
    
}


@end
