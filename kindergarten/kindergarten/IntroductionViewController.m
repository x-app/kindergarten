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

@property (nonatomic, strong) PBViewController *pbVC;

@end

@implementation IntroductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type == CLASS) {
        self.title = @"班级介绍";
        if ([KGUtil getUserCatagory] == 0) { //家长无编辑班级介绍功能
            self.navigationItem.rightBarButtonItem = nil;
        }
    } else if (self.type == GARTEN) {
        self.title = @"园区介绍";
        if ([KGUtil getUserCatagory] != 2) { //非园长无编辑园区介绍功能
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
    self.introImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.introImageView.clipsToBounds = YES;
//    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetail:)];
//    [self.introImageView addGestureRecognizer:tapImage];
    //2015-09-12修改:非园长不具备更新园区介绍功能
    //if (![KGUtil isTeacherVersion]) {
    //    self.navigationItem.rightBarButtonItem = nil;
    //}
    
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

- (PBViewController *)pbVC {
    if (_pbVC == nil) {
        _pbVC = [[PBViewController alloc] init];
        _pbVC.handleVC = self;
        
        PBImageInfo *iInfo = [[PBImageInfo alloc] init];
        iInfo.imageURL = self.picUrl;
        iInfo.imageTitle = @"";
        iInfo.imageDesc = self.introContent;
        
        _pbVC.imageInfos = [NSMutableArray arrayWithObject:iInfo];
    }
    return _pbVC;
}

- (void)showDetail:(UITapGestureRecognizer*)sender {
    //NSLog(@"click image");
//    PBImageInfo *iInfo = [[PBImageInfo alloc] init];
//    iInfo.imageURL = self.picUrl;
//    iInfo.imageTitle = @"";
//    iInfo.imageDesc = self.introContent;

//    PBViewController *pbVC = [[PBViewController alloc] init];
//    pbVC.index = 0;
//    pbVC.handleVC = self;
//    pbVC.imageInfos = [NSMutableArray arrayWithObject:iInfo];
//    [pbVC show];
//    self.pbVC.imageInfos = [NSMutableArray arrayWithObject:iInfo];
    [self.pbVC show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)queryIntroductionData {
    NSDictionary *data = nil;
    NSString *urlSuffix = @"";
    if (self.type == CLASS) {
        data = @{@"classId": @([KGUtil getCurClassId])};
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
        //NSLog(@"JSON: %@", responseObject);
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
    __weak IntroductionViewController *wself = self;
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
                                      UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:wself action:@selector(showDetail:)];
                                      [weakImageView addGestureRecognizer:tapImage];
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
- (void)doPicPicked:(NSArray *)images
{
    if (images == nil || images.count == 0) {
        return;
    }
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Growup" bundle:nil];
    GrowupEditViewController *vc = (GrowupEditViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"GrowDocEdit"];
    
    vc.images = [images mutableCopy];
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

- (void)dealloc {
    NSLog(@"dealloc IntroductionVC");
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
