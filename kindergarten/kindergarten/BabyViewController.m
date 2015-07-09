//
//  BabyViewController.m
//  kindergarten
//
//  Created by slice on 15-7-1.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "BabyViewController.h"
#import "CLLockVC.h"
#import "AppDelegate.h"
@interface BabyViewController ()
@property (nonatomic) NSInteger viewAppearCount;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *func;
@end

@implementation BabyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"BabyViewDidLoad");
    //self.viewAppearCount = 0;
    
    // Do any additional setup after loading the view, typically from a nib.
    
    
    for(int i=0; i<[self.func count]; i++)
    {
        UIImageView* v= self.func[i];
        if(v.tag == 1)
        {
            //[(UIControl *)v addTarget:self action:@selector(onImageClick:) forControlEvents:UIControlEventTouchUpInside];
            
            UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageClick:)];
            [v addGestureRecognizer:singleTap1];
        }
        
    }
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"babyViewController did appear");
    /*AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.user.registered || !delegate.user.verified) {
        NSLog(@"用户尚未注册或者验证没过");
        [CLLockVC showVerifyLockVCInVC:self forgetPwdBlock:^{

        } successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            NSLog(@"验证通过");
            [lockVC dismiss:1.0f];
        }];
    }*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onImageClick:(UIImageView*) sender{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Baby" bundle:nil];
    UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"GrowupView"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
