//
//  GartenViewController.m
//  kindergarten
//
//  Created by slice on 15-7-5.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "GartenViewController.h"
#import "KGUtil.h"
#import "KGImageTableViewController.h"
#import "IntroductionViewController.h"
@interface GartenViewController ()
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *func;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *funcbtns;


@property (weak, nonatomic) IBOutlet UIImageView *repeatImage;

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
    
    if([KGUtil isTeacherVersion])
        [self setTeacherVersionFunc];
    else
        [self setParentVersionFunc];
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
            [self pushWebView:@"cookbook"];
            break;
        }
        case 3:{
            [self pushWebView:@"masterMess"];
            break;
        }
        case 4:{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Child" bundle:nil];
            UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChildView"];
            KGImageTableViewController *cvc = (KGImageTableViewController *)vc;
            if (cvc != nil) {
                cvc.type = TEACHER;
                [self.navigationController pushViewController:cvc animated:YES];
            }
            break;
        }
        case 5:{
            [self pushWebView:@"students"];
            break;
        }
        default:
            break;
    }
}

-(void) setTeacherVersionFunc{
    [super setTeacherVersionFunc];
    for(int i=0; i<self.func.count; i++)
    {
        UIImageView* iv = self.func[i];
        
        if(iv.tag == 5)
            [iv setHidden:false];
    }
    
    for(int i=0; i<self.funcbtns.count; i++)
    {
        UIButton* btn = self.funcbtns[i];
        
        if(btn.tag == 5)
            [btn setHidden:false];
    }
}

-(void) setParentVersionFunc{
    for(int i=0; i<self.func.count; i++)
    {
        UIImageView* iv = self.func[i];
        
        if(iv.tag == 5)
            [iv setHidden:true];
    }
    
    for(int i=0; i<self.funcbtns.count; i++)
    {
        UIButton* btn = self.funcbtns[i];
        
        if(btn.tag == 5)
            [btn setHidden:true];
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
