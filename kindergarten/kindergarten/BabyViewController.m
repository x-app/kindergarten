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
    NSInteger tag = sender.view.tag;
    
    UIViewController *vc = nil;

    NSString *uid = [KGUtil getUser].uid;
    NSString *cid = @"";
    NSString *gid = @"";
    KGChild *child = [KGUtil getCurChild];
    if(child != nil)
        cid = child.cid;
    KGClass *class = [KGUtil getCurClass];
    if(class != nil)
        gid =[ NSString stringWithFormat:@"%ld", (long)class.classId];
    NSString *url = nil;
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
                [self webVC].title = @"健康";
                [self.navigationController pushViewController:[self webVC] animated:YES];
                
                NSString *body = [NSString stringWithFormat:@"dt=%@&g=%@&u=%@", [KGUtil getCompactDateStr], gid, uid];
                url = [KGUtil getRequestHtmlUrl:@"/health/bringmedic" bodyStr:body];
                NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                [[self webVC].webView loadRequest:request];
            }
            
            break;
        }
        case 2:{
            if(![KGUtil isTeacherVersion])
            {
                [self webVC].title = @"晨检";
                [self.navigationController pushViewController:[self webVC] animated:YES];
                
                NSString *body = [NSString stringWithFormat:@"c=%@&dt=%@&u=%@", cid, [KGUtil getCompactDateStr], uid];
                url = [KGUtil getRequestHtmlUrl:@"/health/givemedic" bodyStr:body];
            }
            else
            {
                [self webVC].title = @"点名";
                [self.navigationController pushViewController:[self webVC] animated:YES];
                
                NSString *body = [NSString stringWithFormat:@"dt=%@&g=%@&u=%@", [KGUtil getCompactDateStr], gid, uid];
                url = [KGUtil getRequestHtmlUrl:@"/morningCheck/rollcall" bodyStr:body];
            }
            
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [[self webVC].webView loadRequest:request];
            break;
        }
        case 3:{
            [self webVC].title = @"信箱";
            [self.navigationController pushViewController:[self webVC] animated:YES];
            
            if(![KGUtil isTeacherVersion])
            {
                NSString *body = [NSString stringWithFormat:@"c=%@&dt=%@&u=%@", cid, [KGUtil getCompactDateStr], uid];
                 url = [KGUtil getRequestHtmlUrl:@"/message/parentsmess" bodyStr:body];
            }
            else
            {
                NSString *body = [NSString stringWithFormat:@"dt=%@&g=%@&u=%@", [KGUtil getCompactDateStr], gid, uid];
                url = [KGUtil getRequestHtmlUrl:@"/message/teachermess" bodyStr:body];
            }
            
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [[self webVC].webView loadRequest:request];
            break;
        }
        case 4:{
            if(![KGUtil isTeacherVersion])
            {
                [self webVC].title = @"进园";
                [self.navigationController pushViewController:[self webVC] animated:YES];
                
                NSString *body = [NSString stringWithFormat:@"c=%@&dt=%@&u=%@", cid, [KGUtil getCompactDateStr], uid];
                url = [KGUtil getRequestHtmlUrl:@"/morningCheck/intopark" bodyStr:body];
            }
            else
            {
                [self webVC].title = @"请假处理";
                [self.navigationController pushViewController:[self webVC] animated:YES];
                
                NSString *body = [NSString stringWithFormat:@"dt=%@&g=%@&u=%@", [KGUtil getCompactDateStr], gid, uid];
                url = [KGUtil getRequestHtmlUrl:@"/holiday/list" bodyStr:body];
            }
            
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [[self webVC].webView loadRequest:request];
            break;
        }
        case 5:{
            [self webVC].title = @"离园";
            [self.navigationController pushViewController:[self webVC] animated:YES];
            
            NSString *body = [NSString stringWithFormat:@"c=%@&dt=%@&u=%@", cid, [KGUtil getCompactDateStr], uid];
            NSString *url = [KGUtil getRequestHtmlUrl:@"/morningCheck/outpark" bodyStr:body];
            
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [[self webVC].webView loadRequest:request];
            break;
        }
        case 6:{
            [self webVC].title = @"请假";
            [self.navigationController pushViewController:[self webVC] animated:YES];
            
            NSString *body = [NSString stringWithFormat:@"c=%@&dt=%@&u=%@", cid, [KGUtil getCompactDateStr], uid];
            NSString *url = [KGUtil getRequestHtmlUrl:@"/holiday/askto" bodyStr:body];
            
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [[self webVC].webView loadRequest:request];
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
