//
//  KGUIViewController.m
//  kindergarten
//
//  Created by wangbin on 15/7/11.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGUIViewController.h"
#import "AppDelegate.h"
//#import "CLLockVC.h"
#import "KGUtil.h"
#import "KGPicPicker.h"

@interface KGUIViewController () <UIActionSheetDelegate, KGPicPickerDelegate>

@property (nonatomic) NSInteger tapImageTag; //0表示头像 1是背景图
@property (nonatomic) KGPicPicker *kgpp;

@end

@implementation KGUIViewController

- (WebViewController*)webVC
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.webVC;
}

- (KGPicPicker*)kgpp
{
    if(!_kgpp)
    {
        _kgpp = [[KGPicPicker alloc] initWithUIVC:self needCrop:YES];
        _kgpp.delegate = self;
    }

    return _kgpp;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerBgImageView.userInteractionEnabled = YES;
    self.babyPortraitImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *portraitTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editPortrait)];
    [self.babyPortraitImageView addGestureRecognizer:portraitTap];
    UITapGestureRecognizer *headerBgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editHeaderBg)];
    [self.headerBgImageView addGestureRecognizer:headerBgTap];
    // Do any additional setup after loading the view.
}

- (void)editHeaderBg {
    self.tapImageTag = 1;
    [self editImageAction];
}
- (void)editPortrait {
    self.tapImageTag = 0;
    [self editImageAction];
}

- (void)editImageAction {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", @"恢复默认", nil];
    choiceSheet.actionSheetStyle = UIActionSheetStyleAutomatic;//UIActionSheetStyleBlackTranslucent;
    [choiceSheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        [self.kgpp takePhoto];
    } else if (buttonIndex == 1) {
        // 从相册中选取
        [self.kgpp selectPhoto];
    } else if (buttonIndex == 2) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (self.tapImageTag == 1) {
            self.headerBgImageView.image = [UIImage imageNamed:@"home_top_bg.png"];
            [userDefaults removeObjectForKey:@"headerBgImage"];
        } else if (self.tapImageTag == 0) {
            self.babyPortraitImageView.image = [UIImage imageNamed:@"head.jpg"];
            [userDefaults removeObjectForKey:@"babyPortraitImage"];
        }
        [userDefaults synchronize];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    //NSLog(@"KGUIViewController:viewDidAppear");
//    [self showVerifyLock];
//    
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//     selector:@selector(applicationDidBecomeActiveNotification:)
//     name:UIApplicationDidBecomeActiveNotification
//     object:[UIApplication sharedApplication]];
//    KGChild *curChild = KGUtil.getCurChild;
//    if(curChild)
//    {
//        self.babyNameLabel.text = curChild.name;
//        self.classNameLabel.text = [NSString stringWithFormat:@"%@%@", KGUtil.getVarible.parkName, curChild.className];
//    }
//    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    //[userDefaults setObject:editedImage forKey:@"babyPortraitImage"];
//    NSData *pImageData = (NSData *)[userDefaults objectForKey:@"babyPortraitImage"];
//    if (pImageData != nil) {
//        UIImage *pImage = (UIImage *)[NSKeyedUnarchiver unarchiveObjectWithData: pImageData];
//        if (pImage != nil) {
//            self.babyPortraitImageView.image = pImage;
//        }
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    if ([KGUtil isTeacherVersion]) {
        KGClass *curClass = [KGUtil getCurClass];
        if (curClass) {
            self.babyNameLabel.text = [KGUtil getUser].name;
            self.classNameLabel.text = [NSString stringWithFormat:@"%@%@", KGUtil.getVarible.parkName, curClass.className];
        }
    } else {
        KGChild *curChild = KGUtil.getCurChild;
        if(curChild)
        {
            self.babyNameLabel.text = curChild.name;
            self.classNameLabel.text = [NSString stringWithFormat:@"%@%@", KGUtil.getVarible.parkName, curChild.className];
        }
    }

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //[userDefaults setObject:editedImage forKey:@"babyPortraitImage"];
    NSData *pImageData = (NSData *)[userDefaults objectForKey:@"babyPortraitImage"];
    if (pImageData != nil) {
        UIImage *pImage = (UIImage *)[NSKeyedUnarchiver unarchiveObjectWithData: pImageData];
        if (pImage != nil) {
            self.babyPortraitImageView.image = pImage;
        }
    } else {
        self.babyPortraitImageView.image = [UIImage imageNamed:@"head.jpg"];
    }
    
    NSData *hImageData = (NSData *)[userDefaults objectForKey:@"headerBgImage"];
    if (hImageData != nil) {
        UIImage *hImage = (UIImage *)[NSKeyedUnarchiver unarchiveObjectWithData: hImageData];
        if (hImage != nil) {
            self.headerBgImageView.image = hImage;
        }
    } else {
        self.headerBgImageView.image = [UIImage imageNamed:@"home_top_bg.png"];
    }
}

#pragma mark - KGPicPickerDelegate
- (void)doPicPicked:(UIImage *)image
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData* imageData = [NSKeyedArchiver archivedDataWithRootObject:image];
    NSString *storeKeyName = @"";
    if (self.tapImageTag == 0) {
        storeKeyName = @"babyPortraitImage";
        self.babyPortraitImageView.image = image;
    } else if (self.tapImageTag == 1) {
        storeKeyName = @"headerBgImage";
        self.headerBgImageView.image = image;
    }
    [userDefaults setObject:imageData forKey:storeKeyName];
    [userDefaults synchronize];
}

#pragma mark - push webview
- (void)pushWebView:(NSString *)webViewType
{
    if(webViewType == nil)
        return;
    
    NSString *title = @"";
    
    NSString *curl = @"";
    if ([webViewType isEqual:@"bringmedic"]){
        //健康
        curl = @"/health/bringmedic";
    }
    else if([webViewType isEqual:@"givemedic"]){
        //晨检
        curl = @"/health/givemedic";
    }
    else if([webViewType isEqual:@"rollcall"]){
        //点名
        curl = @"/morningCheck/rollcall";
    }
    else if([webViewType isEqual:@"parentsmess"]){
        //家长信箱
        curl = @"/message/parentsmess";
    }
    else if([webViewType isEqual:@"teachermess"]){
        //教师信箱
        curl = @"/message/teachermess";
    }
    else if([webViewType isEqual:@"intopark"]){
        //进园
        curl = @"/morningCheck/intopark";
    }
    else if([webViewType isEqual:@"holidaylist"]){
        //请假处理
        curl = @"/holiday/list";
    }
    else if([webViewType isEqual:@"outpark"]){
        //出园
        curl = @"/morningCheck/outpark";
    }
    else if([webViewType isEqual:@"askholiday"]){
        //请假
        curl = @"/holiday/askto";
    }
    else if([webViewType isEqual:@"bulletin"]){
        //公告
        curl = @"/message/bulletin";
    }
    else if([webViewType isEqual:@"lesson"]){
        //课程表
        curl = @"/book/lesson";
    }
    else if([webViewType isEqual:@"birthday"]){
        //生日提醒
        curl = @"/book/birthday";
    }
    else if([webViewType isEqual:@"cookbook"]){
        //菜谱
        curl = @"/book/cookbook";
    }
    else if([webViewType isEqual:@"masterMess"]){
        //园长信箱
        curl = @"/message/masterMess";
    }
    else if([webViewType isEqual:@"students"]){
        //班级统计
        curl = @"/statistics/students";
    }
    else if([webViewType isEqual:@"feedback"]){
        //反馈
        curl = @"/FeedBack/prefer";
    }
    else {
        return;
    }
    
    [self webVC].title = title;
    [self.navigationController pushViewController:[self webVC] animated:YES];
    
    NSString *uid = [KGUtil getUser].uid;
    NSInteger cid = 0;
    KGChild *child = [KGUtil getCurChild];
    if(child != nil)
        cid = child.cid;
    NSInteger gid = [KGUtil getCurClassId];
    
    NSString *body = nil;
    if(![KGUtil isTeacherVersion])
    {
        body = [NSString stringWithFormat:@"c=%ld&dt=%@&u=%@", (long)cid, [KGUtil getCompactDateStr], uid];
    }
    else
    {
        body = [NSString stringWithFormat:@"dt=%@&g=%ld&u=%@", [KGUtil getCompactDateStr], (long)gid, uid];
    }
    NSString *url = [KGUtil getRequestHtmlUrl:curl bodyStr:body];
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [[self webVC].webView loadRequest:request];
}

- (void)setTeacherVersionFunc {

}

- (void)setParentVersionFunc {
    
}

/*
- (void)showVerifyLock {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate == nil) {
        NSLog(@"[KGUIViewController viewDidAppear]: delegate is nil");
    }
    if (!delegate.user.verified && !delegate.user.registering) {
        NSLog(@"用户尚未注册或者验证没过");
        [CLLockVC showVerifyLockVCInVC:self forgetPwdBlock:^{
            
        } successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            NSLog(@"验证通过");
            delegate.user.verified = YES;
            [lockVC dismiss:1.0f];
        }];
    }
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
    // Do something here
    [self showVerifyLock];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
