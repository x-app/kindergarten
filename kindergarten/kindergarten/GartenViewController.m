//
//  GartenViewController.m
//  kindergarten
//
//  Created by slice on 15-7-5.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "GartenViewController.h"
#import "KGUtil.h"
#import "ChildTableViewController.h"
#import "IntroductionViewController.h"
@interface GartenViewController ()
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *func;
@property (weak, nonatomic) IBOutlet UIImageView *repeatImage;
@property (weak, nonatomic) IBOutlet UILabel *babyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *classNameLabel;

@end

@implementation GartenViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.repeatImage.image = [self.repeatImage.image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0) resizingMode:UIImageResizingModeTile];
    
    // Do any additional setup after loading the view, typically from a nib.
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
    
    //UIViewController *vc = nil;
    //    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    
    switch (tag){
        case 1:{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Introduction" bundle:nil];
            UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"IntroductionView"];
            IntroductionViewController *ivc = (IntroductionViewController *)vc;
            if (ivc != nil) {
                ivc.type = GARTEN;
                [self.navigationController pushViewController:ivc animated:YES];
            }
            break;
        }
        case 2:{
            [self webVC].title = @"菜谱";
            [self.navigationController pushViewController:[self webVC] animated:YES];
            
            NSString *body = [NSString stringWithFormat:@"c=%@&dt=%@&u=%@", @"2013110", [KGUtil getCompactDateStr], @"20141021172851000015"];
            NSString *url = [KGUtil getRequestHtmlUrl:@"/book/cookbook" bodyStr:body];
            
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [[self webVC].webView loadRequest:request];
            break;
        }
        case 3:{
            [self webVC].title = @"园长信箱";
            [self.navigationController pushViewController:[self webVC] animated:YES];
            
            NSString *body = [NSString stringWithFormat:@"c=%@&dt=%@&u=%@", @"2013110", [KGUtil getCompactDateStr], @"20141021172851000015"];
            NSString *url = [KGUtil getRequestHtmlUrl:@"/message/masterMess" bodyStr:body];
            
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [[self webVC].webView loadRequest:request];
            break;
        }
        case 4:{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Child" bundle:nil];
            UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChildView"];
            ChildTableViewController *cvc = (ChildTableViewController *)vc;
            if (cvc != nil) {
                cvc.type = TEACHER;
                [self.navigationController pushViewController:cvc animated:YES];
            }
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
