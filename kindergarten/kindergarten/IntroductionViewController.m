//
//  IntroductionViewController.m
//  kindergarten
//
//  Created by wangbin on 15/7/22.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "IntroductionViewController.h"
#import "KGConst.h"
#import "KGUtil.h"
#import "UIImageView+WebCache.h"
#import "PBViewController.h"
#import "KGPicPicker.h"
#import "GrowupEditViewController.h"
@interface IntroductionViewController ()<UIActionSheetDelegate, KGPicPickerDelegate, KGPostImageDelegate>

@property (nonatomic, strong) KGPicPicker *picPicker;

@end

@implementation IntroductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type == CLASS) {
        self.title = @"班级介绍";
    } else if (self.type == GARTEN) {
        self.title = @"园区介绍";
    }
    self.introImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.introImageView.clipsToBounds = YES;
//    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetail:)];
//    [self.introImageView addGestureRecognizer:tapImage];
    if (![KGUtil isTeacherVersion]) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self queryIntroductionData];
    // Do any additional setup after loading the view.
}

- (KGPicPicker *)picPicker {
    if(_picPicker == nil) {
        _picPicker = [[KGPicPicker alloc] initWithUIVC:self needCrop:FALSE];
        _picPicker.delegate = self;
    }
    return _picPicker;
}

- (void)showDetail:(UITapGestureRecognizer*) sender {
    NSLog(@"click image");
    PBImageInfo *iInfo = [[PBImageInfo alloc] init];
    iInfo.imageURL = self.picUrl;
    iInfo.imageTitle = @"";
    iInfo.imageDesc = self.introContent;

    PBViewController *pbVC = [[PBViewController alloc] init];
    pbVC.index = 0;
    pbVC.handleVC = self;
    pbVC.imageInfos = [NSMutableArray arrayWithObject:iInfo];
    [pbVC show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    CGRect barFrame = self.navigationController.navigationBar.frame;
    NSLog(@"barFrame frame: %f %f %f %f", barFrame.origin.x, barFrame.origin.y,
          barFrame.size.width, barFrame.size.height);
    NSLog(@"textview frame: %f %f %f %f", self.introTextView.frame.origin.x, self.introTextView.frame.origin.y,
          self.introTextView.frame.size.width, self.introTextView.frame.size.height);
    NSLog(@"imageview frame: %f %f %f %f", self.introImageView.frame.origin.x, self.introImageView.frame.origin.y,
          self.introImageView.frame.size.width, self.introImageView.frame.size.height);
}

- (void)queryIntroductionData {
    NSDictionary *data = nil;
    NSString *urlSuffix = @"";
    if (self.type == CLASS) {
        data = @{@"classId": @([[KGUtil getCurChild] classId])};
        urlSuffix = @"/system/queryClassDesc";
    } else if (self.type == GARTEN) {
        data = @{};
        urlSuffix = @"/system/queryKindergartenDesc";
    } else {
        NSLog(@"wrong type");
        return;
    }
    NSDictionary *body = [KGUtil getRequestBody:data];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:urlSuffix];
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            NSArray *objlist = (NSArray *)[responseObject objectForKey:@"objlist"];
            if (objlist == nil || [objlist count] == 0) {
                return;
            }
            NSDictionary *obj = [objlist objectAtIndex:0];
            self.smallPicUrl = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], [obj objectForKey:@"smallPicUrl"]];
            self.picUrl = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], [obj objectForKey:@"picUrl"]];
            self.introContent = [obj objectForKey:@"description"];
            [self showIntroduction];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    } inView:self.view showHud:YES showError:true];
}

- (void)showIntroduction {
    __block UIActivityIndicatorView *activityIndicator;
    __weak UIImageView *weakImageView = self.introImageView;
    [self.introImageView sd_setImageWithURL:[NSURL URLWithString:self.smallPicUrl]
                           placeholderImage:[UIImage imageNamed:@"image_placeholder"]
                                    options:SDWebImageProgressiveDownload
                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                       if (!activityIndicator) {
                                           activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                                           [weakImageView addSubview:activityIndicator];
                                           activityIndicator.center = weakImageView.center;
                                           [activityIndicator startAnimating];
                                       }
                                   }
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      [activityIndicator removeFromSuperview];
                                      activityIndicator = nil;
                                      UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetail:)];
                                      [self.introImageView addGestureRecognizer:tapImage];
                                  }];
    self.introTextView.text = self.introContent;
}

- (void)addIntroduction {
    if (![KGUtil isTeacherVersion]) {
        return;
    }
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

- (void)deleteIntroduction:(NSInteger)descId {
    if (![KGUtil isTeacherVersion]) {
        return;
    }
    NSDictionary *data = nil;
    NSString *urlSuffix = @"";
    if (self.type == CLASS) {
        data = @{};
        urlSuffix = @"/system/deleteClassDesc";
    } else if (self.type == GARTEN) {
        data = @{};
        urlSuffix = @"/system/deleteKindergartenDesc";
    } else {
        return;
    }
    NSDictionary *body = [KGUtil getRequestBody:data];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:urlSuffix];
    UIView *view = [KGUtil getTopMostViewController].view;
    BOOL showHud = (view != nil);
    [KGUtil postRequest:url
             parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    NSString *code = [responseObject objectForKey:@"code"];
                    if ([code isEqualToString:@"000000"]) {
                        
                    } else {
                        [KGUtil showCheckMark:@"删除失败" checked:NO inView:view];
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                    [KGUtil showCheckMark:@"请求删除失败" checked:NO inView:view];
                }
                 inView:view
                showHud:showHud
              showError:true];
}


#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        [self.picPicker takePhoto];
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        [self.picPicker selectPhoto];
    }
}

#pragma mark - KGPicPickerDelegate
- (void)doPicPicked:(UIImage *)image
{
    //    NSLog(@"get image");
    if(image == nil)
        return;
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Growup" bundle:nil];
    GrowupEditViewController *vc = (GrowupEditViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"GrowDocEdit"];
    
    vc.image = image;
    vc.delegate = self;
    if (self.type == CLASS) {
        vc.postType = ADD_CLASS_DESC;
    } else if (self.type == GARTEN) {
        vc.postType = ADD_GARTEN_DESC;
    } else {
        return;
    }
    [self presentViewController:vc animated:YES
                     completion:^(void){
                     }];
}

#pragma mark - KGPostImageDelegate
- (void)reloadData {
    [self queryIntroductionData];
}

- (IBAction)updateButtonAction:(id)sender {
    [self addIntroduction];
}


/*
 {
 "createTime": "2014-12-27 21:41:04",
 "picUrl": "/test/201402.jpg",
 "classId": 101021021,
 "description": "大一班介绍测试",
 "classDescId": 2,
 "smallPicUrl": "/test/201402_l.jpg"
 },
 {
 "createTime": "2014-12-27 21:40:09",
 "picUrl": "/test/2014.jpg",
 "classId": 101021021,
 "description": "大一班介绍",
 "classDescId": 1,
 "smallPicUrl": "/test/2014_l.jpg"
 }
 
 */

/*
 
 {
 "kindergartenDescId": 2,
 "createTime": "2014-12-27 21:49:47",
 "picUrl": "/test/2014122704.jpg",
 "description": "园区介绍2",
 "smallPicUrl": "/test/2014122704_l.jpg"
 },
 {
 "kindergartenDescId": 1,
 "createTime": "2014-12-27 21:48:56",
 "picUrl": "/test/2014122703.jpg",
 "description": "园区介绍",
 "smallPicUrl": "/test/2014122703_l.jpg"
 }
 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
