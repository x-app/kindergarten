//
//  BabyViewController.m
//  kindergarten
//
//  Created by slice on 15-7-1.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "BabyViewController.h"
#import "WebViewController.h"
#import "CLLockVC.h"
#import "AppDelegate.h"

@interface BabyViewController ()
@property (nonatomic) NSInteger viewAppearCount;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *func;

@property (strong, nonatomic)WebViewController *webVC;

@end

@implementation BabyViewController

- (WebViewController*)webVC
{
    if(_webVC == nil)
        _webVC = [[WebViewController alloc] init];

    return _webVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"BabyViewDidLoad");
    
    //self.viewAppearCount = 0;
    
    // Do any additional setup after loading the view, typically from a nib.
    for(int i=0; i<[self.func count]; i++)
    {
        UIImageView* v= self.func[i];
        //[(UIControl *)v addTarget:self action:@selector(onImageClick:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageClick:)];
        [v addGestureRecognizer:singleTap1];
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
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Baby" bundle:nil];
            vc = [storyBoard instantiateViewControllerWithIdentifier:@"PickupView"];
            break;
        }
        case 2:{            
            [self.navigationController pushViewController:[self webVC] animated:YES];
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.sina.com"]];
            [[self webVC].webView loadRequest:request];
            break;
        }
        case 3:{
            [self.navigationController pushViewController:[self webVC] animated:YES];
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
            [[self webVC].webView loadRequest:request];
            break;
        }
        case 7:{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Baby" bundle:nil];
            vc = [storyBoard instantiateViewControllerWithIdentifier:@"GrowupView"];
            break;
        }
        default:
            break;
    }
    
    if(vc != nil)
        [self.navigationController pushViewController:vc animated:YES];
}

@end
