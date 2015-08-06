//
//  ClassViewController.m
//  kindergarten
//
//  Created by slice on 15-7-1.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "ClassViewController.h"
#import "KGUtil.h"
#import "KGImageTableViewController.h"
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

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onImageClick:(UITapGestureRecognizer*) sender{
    //NSLog(@"%ld", (long)sender.view.tag);
    NSInteger tag = sender.view.tag;
    
    UIViewController *vc = nil;

    switch (tag){
        case 1:{
            [self pushWebView:@"bulletin"];
            break;
        }
        case 2:{
            [self pushWebView:@"lesson"];
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
            [self pushWebView:@"birthday"];
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
            KGImageTableViewController *cvc = (KGImageTableViewController *)vc;
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
