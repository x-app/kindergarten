//
//  KGUIViewController.m
//  kindergarten
//
//  Created by wangbin on 15/7/11.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGUIViewController.h"
#import "AppDelegate.h"
#import "KGConst.h"
#import "KGUtil.h"
#import "KGPicPicker.h"
#import "MLTableAlert.h"

@interface KGUIViewController () <UIActionSheetDelegate, KGPicPickerDelegate>

@property (nonatomic) NSInteger tapImageTag; //0表示头像 1是背景图
@property (nonatomic) KGPicPicker *kgpp;
@property (nonatomic) NSString *headBGPicName;
@property (nonatomic) NSString *headPortraitPicName;
@property (nonatomic) NSString *portraitKey;//NSDefaults的portraitKey
@property (nonatomic) NSString *topbgKey;//NSDefaults的topbgKey

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *repeatImgTopVertical;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *repeatImgHeight;

@end

@implementation KGUIViewController

//- (WebViewController*)webVC
//{
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    return delegate.webVC;
//}

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
    
    // add change user event
    UITapGestureRecognizer *childLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(babyLabelTouchUpInside:)];
    UITapGestureRecognizer *childLabelTapGestureRecognizer2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(babyLabelTouchUpInside:)];
    UITapGestureRecognizer *classLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(classLabelTouchUpInside:)];
    UITapGestureRecognizer *classLabelTapGestureRecognizer2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(classLabelTouchUpInside:)];
    
    [self.childNameLabel addGestureRecognizer:childLabelTapGestureRecognizer];
    [self.classNameLabel addGestureRecognizer:classLabelTapGestureRecognizer];

    [self.childSelImg addGestureRecognizer:childLabelTapGestureRecognizer2];
    [self.classSelImg addGestureRecognizer:classLabelTapGestureRecognizer2];
}

-(void)viewDidLayoutSubviews
{
    //    [((UIScrollView *)self.view) setContentSize: CGSizeMake(screen_width, screen_height)];
    //NSLog(@"%f", screen_height);
    if(screen_height < 1136)//4/4s
    {
        self.topSpace.constant = -10;
        self.repeatImgHeight.constant = 0;
        //    self.repeatImgTopVertical.constant = -50;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    //NSLog(@"KGUIViewController:viewDidAppear");
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.curKGVC = self;
}

- (void)viewWillAppear:(BOOL)animated {
    if([KGUtil isTeacherVersion]){
        _headBGPicName = @"home_top_bg3.png";
        _headPortraitPicName = @"teacher_home_head_img.png";
        _portraitKey = @"teacher_portrait_img";
        _topbgKey = @"teacher_topbg_img";
    }else {
        _headBGPicName = @"home_top_bg5.png";
        
        _headPortraitPicName = @"parent_home_head_img.png";
        _portraitKey = @"parent_portrait_img";
        _topbgKey = @"parent_topbg_img";
    }
    
    if ([KGUtil isTeacherVersion]) {
        self.childNameLabel.textColor = [UIColor colorWithRed:223/255.0 green:44/255.0 blue:79/255.0 alpha:1];
        
        KGClass *curClass = [KGUtil getCurClass];
        if (curClass) {
            self.childNameLabel.text = [KGUtil getUser].name;
            self.classNameLabel.text = [NSString stringWithFormat:@"%@%@", KGUtil.getVarible.parkName, curClass.className];
        }
    } else {
        self.childNameLabel.textColor = [UIColor colorWithRed:0/255.0 green:152/255.0 blue:83/255.0 alpha:1];
        
        KGChild *curChild = KGUtil.getCurChild;
        if(curChild)
        {
            self.childNameLabel.text = curChild.name;
            self.classNameLabel.text = [NSString stringWithFormat:@"%@%@", KGUtil.getVarible.parkName, curChild.className];
        }
    }
    
    if([KGUtil isTeacherVersion])
    {
        if([[KGUtil getClasses] count] > 1)
            self.classSelImg.hidden = false;
        else
            self.classSelImg.hidden = true;
        
        self.childSelImg.hidden = true;
    }
    else
    {
        self.classSelImg.hidden = true;
        if([[KGUtil getChilds] count] > 1)
            self.childSelImg.hidden = false;
        else
            self.childSelImg.hidden = true;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //portrait
    NSData *pImageData = (NSData *)[userDefaults objectForKey:self.portraitKey];
    if (pImageData != nil) {
        UIImage *pImage = (UIImage *)[NSKeyedUnarchiver unarchiveObjectWithData: pImageData];
        if (pImage != nil) {
            self.babyPortraitImageView.image = pImage;
        }
    } else {
        self.babyPortraitImageView.image = [UIImage imageNamed:self.headPortraitPicName];
    }
    //bg
    NSData *hImageData = (NSData *)[userDefaults objectForKey:self.topbgKey];
    if (hImageData != nil) {
        UIImage *hImage = (UIImage *)[NSKeyedUnarchiver unarchiveObjectWithData: hImageData];
        if (hImage != nil) {
            self.headerBgImageView.image = hImage;
        }
    } else {
        self.headerBgImageView.image = [UIImage imageNamed:self.headBGPicName];
    }
}

#pragma mark -
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
        // 恢复默认
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (self.tapImageTag == 1) {
            self.headerBgImageView.image = [UIImage imageNamed:self.headBGPicName];
            [userDefaults removeObjectForKey:self.topbgKey];
        } else if (self.tapImageTag == 0) {
            self.babyPortraitImageView.image = [UIImage imageNamed:self.headPortraitPicName];
            [userDefaults removeObjectForKey:self.portraitKey];
        }
        [userDefaults synchronize];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KGPicPickerDelegate
- (void)doPicPicked:(NSArray *)images
{
    if (images == nil || images.count == 0) {
        return;
    }
    UIImage *image = (UIImage *)[images objectAtIndex:0];
    if (image == nil) {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData* imageData = [NSKeyedArchiver archivedDataWithRootObject:image];
    NSString *storeKeyName = @"";
    if (self.tapImageTag == 0) {
        storeKeyName = self.portraitKey;
        self.babyPortraitImageView.image = image;
    } else if (self.tapImageTag == 1) {
        storeKeyName = self.topbgKey;
        self.headerBgImageView.image = image;
    }
    [userDefaults setObject:imageData forKey:storeKeyName];
    [userDefaults synchronize];
}

- (void)pushWebView:(NSString *)webViewType
{
    [KGUtil pushWebView:webViewType inViewController:self];
}

#pragma mark - label touch
-(void) babyLabelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    
//    UILabel *label=(UILabel*)recognizer.view;
//    NSLog(@"%@被点击了",label.text);
    if([KGUtil isTeacherVersion])
        return;

    MLTableAlert *tableAlert = [MLTableAlert tableAlertWithTitle:@"宝宝选择" cancelButtonTitle:@"取消" numberOfRows:^NSInteger(NSInteger section) {
            if(![KGUtil isTeacherVersion])
            {
                return [KGUtil getChilds].count;
            }
            return 0;
        }
        andCells:^UITableViewCell *(MLTableAlert *alert, NSIndexPath *indexPath) {
            static NSString *CellIdentifier = @"CellIdentifier";
            UITableViewCell *cell = [alert.table dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            if(![KGUtil isTeacherVersion])
            {
                KGChild *child = [[KGUtil getChilds] objectAtIndex:indexPath.row];
                
                cell.textLabel.text = child.name;
                return cell;

            }
            return nil;
        }];
    
    
        // Setting custom alert height
        tableAlert.height = 50;
    
    // configure actions to perform
    [tableAlert configureSelectionBlock:^(NSIndexPath *selectedIndex){
        if(![KGUtil isTeacherVersion])
        {
            KGChild *child = [[KGUtil getChilds] objectAtIndex:selectedIndex.row];
            self.childNameLabel.text = child.name;
            
            [KGUtil setCurChildId:selectedIndex.row];
        }
    } andCompletionBlock:^{
        NSLog(@"cancelled");
    }];
    
    // show the alert
    [tableAlert show];
    
}

-(void) classLabelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    if(![KGUtil isTeacherVersion])
        return;
    
    MLTableAlert *tableAlert = [MLTableAlert tableAlertWithTitle:@"班级选择" cancelButtonTitle:@"取消" numberOfRows:^NSInteger(NSInteger section) {
        if([KGUtil isTeacherVersion])
        {
            return [KGUtil getClasses].count;
        }
        return 0;
    }
    andCells:^UITableViewCell *(MLTableAlert *alert, NSIndexPath *indexPath) {
        static NSString *CellIdentifier = @"CellIdentifier";
        UITableViewCell *cell = [alert.table dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        if([KGUtil isTeacherVersion])
        {
            KGClass *class = [[KGUtil getClasses] objectAtIndex:indexPath.row];
            
            cell.textLabel.text = class.className;
            return cell;
            
        }
        return nil;
    }];
    
    
    // Setting custom alert height
    tableAlert.height = 50;
    
    // configure actions to perform
    [tableAlert configureSelectionBlock:^(NSIndexPath *selectedIndex){
        if([KGUtil isTeacherVersion])
        {
            KGClass *class = [[KGUtil getClasses] objectAtIndex:selectedIndex.row];
            self.classNameLabel.text = [NSString stringWithFormat:@"%@%@", KGUtil.getVarible.parkName, class.className];
            
            [KGUtil setCurClassId:selectedIndex.row];
        }
    } andCompletionBlock:^{
        NSLog(@"cancelled");
    }];
    
    // show the alert
    [tableAlert show];
}

#pragma mark -
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
