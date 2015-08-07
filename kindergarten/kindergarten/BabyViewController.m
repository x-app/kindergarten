//
//  BabyViewController.m
//  kindergarten
//
//  Created by slice on 15-7-1.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "BabyViewController.h"
#import "KGUtil.h"
#import "AppDelegate.h"
#import "KGChild.h"
@interface BabyViewController ()

@property (nonatomic) NSInteger viewAppearCount;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *func;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *funcbtns;


@property (weak, nonatomic) IBOutlet UIImageView *repeatImage;

@end

@implementation BabyViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"BabyViewDidLoad");
   
    self.repeatImage.image = [self.repeatImage.image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0) resizingMode:UIImageResizingModeTile];
    
    for(int i=0; i<[self.func count]; i++)
    {
        UIImageView* v= self.func[i];
        //[(UIControl *)v addTarget:self action:@selector(onImageClick:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageClick:)];
        [v addGestureRecognizer:singleTap1];
    }
    
    if([KGUtil isTeacherVersion])
        [self setTeacherVersionFunc];
    }

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // 通过点击push message冷启动应用，切换push到的type页面。
    // 仅在这里增加切换逻辑，因为这里是冷启动的唯一主页面
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(delegate.isLaunchedByNotification)
    {
        delegate.isLaunchedByNotification = false;//只切换一次
        if(delegate.myPushType != nil && [delegate.myPushType length] == 0)
            [self pushWebView:delegate.myPushType];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onImageClick:(UITapGestureRecognizer*) sender{
    NSInteger tag = sender.view.tag;
    
    UIViewController *vc = nil;

    switch (tag){
        case 1:{
            if(![KGUtil isTeacherVersion])
            {
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Baby" bundle:nil];
                vc = [storyBoard instantiateViewControllerWithIdentifier:@"PickupView"];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                [self pushWebView:@"bringmedic"];
            }
            
            break;
        }
        case 2:{
            [self pushWebView:@"givemedic"];
//            if(![KGUtil isTeacherVersion])
//            {
//                [self webVC].title = @"晨检";
//                [self.navigationController pushViewController:[self webVC] animated:YES];
//                
//                NSString *body = [NSString stringWithFormat:@"c=%ld&dt=%@&u=%@", (long)cid, [KGUtil getCompactDateStr], uid];
//                url = [KGUtil getRequestHtmlUrl:@"/health/givemedic" bodyStr:body];
//            }
//            else
//            {
//                [self webVC].title = @"点名";
//                [self.navigationController pushViewController:[self webVC] animated:YES];
//                
//                NSString *body = [NSString stringWithFormat:@"dt=%@&g=%ld&u=%@", [KGUtil getCompactDateStr], (long)gid, uid];
//                url = [KGUtil getRequestHtmlUrl:@"/morningCheck/rollcall" bodyStr:body];
//            }
//            
//            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//            [[self webVC].webView loadRequest:request];
            break;
        }
        case 3:{
            if(![KGUtil isTeacherVersion])
            {
                [self pushWebView:@"parentsmess"];
            }
            else
            {
                [self pushWebView:@"teachermess"];
            }
            break;
        }
        case 4:{
            if(![KGUtil isTeacherVersion])
            {
                [self pushWebView:@"intopark"];
            }
            else
            {
                [self pushWebView:@"holidaylist"];
            }
            break;
        }
        case 5:{
            [self pushWebView:@"outpark"];
            break;
        }
        case 6:{
            [self pushWebView:@"askholiday"];
            break;
        }
        case 7:{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Baby" bundle:nil];
            vc = [storyBoard instantiateViewControllerWithIdentifier:@"GrowupView"];
            
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}

-(void) setTeacherVersionFunc{
    for(int i=0; i<self.func.count; i++)
    {
        UIImageView* iv = self.func[i];
        
        if(iv.tag == 1)
            [iv setImage:[UIImage imageNamed:@"home_health.png"]];
        else if(iv.tag ==2)
            [iv setImage:[UIImage imageNamed:@"home_roll.png"]];
        else if(iv.tag == 4)
            [iv setImage:[UIImage imageNamed:@"home_leave.png"]];
        if(iv.tag >= 5)
            [iv setHidden:true];
    }
    
    for(int i=0; i<self.funcbtns.count; i++)
    {
        UIButton* btn = self.funcbtns[i];
        if([btn.titleLabel.text  isEqual: @"接送授权"])
           [btn setTitle:@"健康" forState:UIControlStateNormal];
        else if([btn.titleLabel.text  isEqual: @"晨检"])
            [btn setTitle:@"点名" forState:UIControlStateNormal];
        else if([btn.titleLabel.text  isEqual: @"信箱"]){
            
        }
        else if([btn.titleLabel.text  isEqual: @"进园"])
            [btn setTitle:@"请假处理" forState:UIControlStateNormal];
        else
            [btn setHidden:true];
    }
}

@end
