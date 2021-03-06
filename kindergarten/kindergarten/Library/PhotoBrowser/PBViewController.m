//
//  PhotoBrowserViewController.m
//  photobrowser
//
//  Created by wangbin on 15/7/20.
//  Copyright (c) 2015年 netmad. All rights reserved.
//

#import "PBViewController.h"
#import "AppDelegate.h"
#import "KGUtil.h"
@interface PBViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *menuItems;

@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBarHeightC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarHeightC;
@property (weak, nonatomic) IBOutlet UIView *bottomBarView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) id oldDelegate;

@end

const CGFloat segWidth = 20.f;

@implementation PBViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self vcPrepare];
    //self.navigationController.delegate = self;
    
    /*UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0 , 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
    titleLabel.font = [UIFont boldSystemFontOfSize:12];  //设置文本字体与大小
    titleLabel.textColor = [UIColor whiteColor];  //设置文本颜色
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"";
    self.navigationItem.titleView = titleLabel;*/
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setBackBarButtonItem:nil];
    
    self.scrollView.backgroundColor = [UIColor blackColor];
    if (!self.showOneMenuOnly) {
        [self.menuItems addObject:[KxMenuItem menuItem:@"保存至本地相册"
                                                 image:[UIImage imageNamed:@"icon_save.png"]
                                                target:self
                                                action:@selector(saveImageToLocalAlbum:)]];
    }
    [self setNeedsStatusBarAppearanceUpdate];
    
    //self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    //self.navigationController.interactivePopGestureRecognizer.delegate = self;
    //[self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
    //[self.navigationController.interactivePopGestureRecognizer addTarget:self action:@selector(dismiss)];
    
    // Do any additional setup after loading the view.
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return [gestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class];
//}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (NSMutableArray *)menuItems {
    if (_menuItems == nil) {
        _menuItems = [[NSMutableArray alloc] init];
    }
    return _menuItems;
}

- (void)addAMenuItem:(NSString *)title
                icon:(UIImage *)image
              target:(id)trgt
              action:(SEL)selector {
    [self.menuItems addObject:[KxMenuItem menuItem:title
                                             image:image
                                            target:trgt
                                            action:selector]];
}


- (void)showMenuItem:(NSString *)title
                icon:(UIImage *)image
              target:(id)trgt
              action:(SEL)selector {
    self.showOneMenuOnly = YES;
    [self.menuItems removeAllObjects];
    [self.menuItems addObject:[KxMenuItem menuItem:title
                                             image:image
                                            target:trgt
                                            action:selector]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/** 真正展示 */
-(void)show{
    [self pagesPrepare];
    //[self cleanPhotoBrowser];
    [self pushPhotoVC];
}


/** push */
-(void)pushPhotoVC {
    if (_handleVC.navigationController) {
        [_handleVC.navigationController pushViewController:self animated:YES];
    } else {
        [_handleVC presentViewController:self animated:YES completion:^{
            
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isVisible = NO;
    [KxMenu dismissMenu];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self restoreNavigationBarStyle];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isVisible = YES;
    [self setNavigationBarStyle];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setNavigationBarStyle];
}
//
//-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    NSLog(@"pb in navigation delegate!");
//    if (viewController == self) {
//        /*UIImage *rightImage = [UIImage imageNamed:@"gallery_more_icon.png"];
//        if (self.showOneMenuOnly && self.menuItems.count >= 1) {
//            KxMenuItem *menuItem = [self.menuItems objectAtIndex:0];
//            if (menuItem != nil) {
//                rightImage = menuItem.image;
//            }
//        }
//        UIImageView *rightImageView = [[UIImageView alloc] initWithImage:rightImage];
//        rightImageView.contentMode = UIViewContentModeScaleAspectFill;
//        rightImageView.frame = CGRectMake(5, 0, 10, 20);
//        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//        [rightButton addTarget:self action:@selector(clickRightButton:) forControlEvents:UIControlEventTouchUpInside];
//        [rightButton addSubview:rightImageView];
//        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
//        self.navigationItem.rightBarButtonItem = rightButtonItem;*/
//        [self setNavigationBarStyle];
//    } else {
//        [self restoreNavigationBarStyle];
//    }
//}

- (void)cleanPhotoBrowser {
    //NSLog(@">>>>clear photobrowser");
    for (int i = 0; i < self.scrollView.subviews.count; i++) {
        UIView *view = [self.scrollView.subviews objectAtIndex:i];
        [view removeFromSuperview];
    }
    //[self.reusablePhotoItemViewSetM removeAllObjects];
    [self.visiblePhotoItemViewDictM removeAllObjects];
}

- (IBAction)rightButtonAction:(id)sender {
    NSLog(@"right button touch up inside");
    if (self.showOneMenuOnly && self.menuItems.count >= 1) {
        KxMenuItem *menuItem = [self.menuItems objectAtIndex:0];
        if (menuItem == nil) {
            return;
        }
        if (menuItem.target && [menuItem.target respondsToSelector:menuItem.action]) {
            [menuItem.target performSelectorOnMainThread:menuItem.action withObject:self waitUntilDone:YES];
        }
    } else {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        //CGRect rect = CGRectMake(screenBounds.size.width - 80, self.navigationController.navigationBar.frame.origin.y, 100, self.navigationController.navigationBar.frame.size.height);
        CGRect rect = CGRectMake(screenBounds.size.width - 80, self.topBarView.frame.origin.y, 100, self.topBarView.frame.size.height);
        for (int i = 0; i < _menuItems.count; i++) {
            KxMenuItem *item = (KxMenuItem *)[_menuItems objectAtIndex:i];
            item.imageIndex = self.page;
            item.rowIndex = self.rowIndex;
            item.sectionIndex = self.sectionIndex;
        }
        [KxMenu showMenuInView:self.view
                      fromRect:rect
                     menuItems:self.menuItems];
    }
}

- (IBAction)leftButtonAction:(id)sender {
    [self dismiss];
}

- (void)clickRightButton:(UIButton *)sender {
    if (self.showOneMenuOnly && self.menuItems.count >= 1) {
        KxMenuItem *menuItem = [self.menuItems objectAtIndex:0];
        if (menuItem == nil) {
            return;
        }
        if (menuItem.target && [menuItem.target respondsToSelector:menuItem.action]) {
            [menuItem.target performSelectorOnMainThread:menuItem.action withObject:self waitUntilDone:YES];
        }
    } else {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGRect rect = CGRectMake(screenBounds.size.width - 80, self.navigationController.navigationBar.frame.origin.y, 100, self.navigationController.navigationBar.frame.size.height);
        for (int i = 0; i < _menuItems.count; i++) {
            KxMenuItem *item = (KxMenuItem *)[_menuItems objectAtIndex:i];
            item.imageIndex = self.page;
            item.rowIndex = self.rowIndex;
            item.sectionIndex = self.sectionIndex;
        }
        [KxMenu showMenuInView:self.view
                      fromRect:rect
                     menuItems:self.menuItems];
    }
}

- (void)saveImageToLocalAlbum: (id)sender {
    UIImage *curImage = self.currentItemView.photoImageView.image;
    if (curImage == nil) {
        return;
    }
    UIImageWriteToSavedPhotosAlbum(curImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image: (UIImage *)image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil;
    BOOL successFlag = NO;
    if(error != NULL){
        msg = @"保存图片失败" ;
        successFlag = NO;
    } else{
        msg = @"保存图片成功" ;
        successFlag = YES;
    }
    [KGUtil showCheckMark:msg checked:successFlag inView:self.view];
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];*/
}

- (void)setNavigationBarStyle {
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.translucent = YES;
//    self.navigationController.navigationBar.alpha = 1.0;
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //self.navigationItem.hidesBackButton = YES;
    //self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0);
    //self.navigationItem.leftBarButtonItem.tintColor = [UIColor redColor];
    //[self.navigationController.navigationBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    self.navigationController.navigationBar.alpha = 0;
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationItem.hidesBackButton = YES;
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    if (self.showOneMenuOnly && self.menuItems.count >= 1) {
        KxMenuItem *menuItem = [self.menuItems objectAtIndex:0];
        if (menuItem != nil) {
            UIImageView *rightButtonImageView = [[UIImageView alloc] initWithImage:menuItem.image];
            rightButtonImageView.frame = CGRectMake(0, 0, 20, 20);
            [self.rightButton setImage:menuItem.image forState:UIControlStateNormal];
        }
    }
}

- (void)restoreNavigationBarStyle {
//    self.navigationController.navigationBar.tintColor = nil;
//    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
//    self.navigationController.navigationBar.translucent = NO;
    //self.navigationItem.hidesBackButton = NO;
    //self.navigationController.navigationBar.frame = CGRectMake(0, 24, [UIScreen mainScreen].bounds.size.width, 40);
    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    self.navigationController.navigationBar.alpha = 1;
//    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
//    self.navigationController.navigationBar.tintColor = nil;
    //self.navigationItem.hidesBackButton = NO;
}



/*
 *  控制器准备
 */
-(void)vcPrepare{
    
    //去除自动处理
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //每页准备
    [self pagesPrepare];
    
    //间距
    _scrollViewRightMarginC.constant = -segWidth;
}



/** 每页准备 */
-(void)pagesPrepare {
    if (self.imageInfos == nil || self.imageInfos.count == 0) {
        return;
    }
    __block CGRect frame = [UIScreen mainScreen].bounds;
    
    CGFloat widthEachPage = frame.size.width + segWidth;
    
    //[self.reusablePhotoItemViewSetM removeAllObjects];
    //[self.visiblePhotoItemViewDictM removeAllObjects];
    [self cleanPhotoBrowser];

    //展示页码对应的页面
    [self showWithPage:self.index];
    //self.page = self.index;
    //设置contentSize
    //self.scrollView.frame = CGRectMake(widthEachPage * self.imageInfos.count, 0, widthEachPage * (self.imageInfos.count + 1), frame.size.height);
    self.scrollView.contentSize = CGSizeMake(widthEachPage * self.imageInfos.count, 0);
    self.scrollView.isScrollToIndex = NO;
    self.scrollView.index = _index;
}

- (void)resetAsPageRemoved {
    NSInteger nextPage = self.page;
    if (nextPage < 0 || nextPage >= self.imageInfos.count) {
        nextPage = self.imageInfos.count - 1;
    }
    [self resetToIndex:nextPage];
}

- (void)resetToIndex: (NSInteger)index{
    if (!self.isVisible) {
        return;
    }
    if (self.imageInfos == nil || self.imageInfos.count == 0) {
        [self dismiss];
    }
    [self cleanPhotoBrowser];
    self.index = index;
    [self pagesPrepare];
}

/*
 *  展示页码对应的页面
 */
-(void)showWithPage:(NSUInteger)page{
    if (self.imageInfos == nil || self.imageInfos.count == 0) {
        return;
    }

//    PBImageInfo *curImgInfo = (PBImageInfo *)[self.imageInfos objectAtIndex:page];
//    NSString *text = curImgInfo.imageTitle;
//    if ([KGUtil isEmptyString:text]) {
//        text = [NSString stringWithFormat:@"%@ / %@", @(page + 1) , @(self.imageInfos.count)];
//    }
//    UILabel *titleLabel = (UILabel *)self.navigationItem.titleView;
//    if (titleLabel != nil) {
//        titleLabel.text = text;
//    }
    //如果对应页码对应的视图正在显示中，就不用再显示了
    if([self.visiblePhotoItemViewDictM objectForKey:@(page)] != nil) return;

    //取出重用photoItemView
    /*PBItemView *photoItemView = [self dequeReusablePhotoItemView];
    
    if(photoItemView == nil){//没有取到
        
        //重新创建
        photoItemView = [[[NSBundle mainBundle] loadNibNamed:@"PBItemView" owner:nil options:nil] firstObject];
    }*/
    PBItemView *photoItemView = [[[NSBundle mainBundle] loadNibNamed:@"PBItemView" owner:nil options:nil] firstObject];
    //NSLog(@"%p",&photoItemView);

    __weak PBViewController *wself = self;
    //数据覆盖
    photoItemView.ItemViewSingleTapBlock = ^(){
        [wself singleTap];
    };
    /*photoItemView.viewZoomBlock = ^() {
//        [self.navigationController.navigationBar setNeedsDisplay];
//        self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
//        [self.navigationController.view setNeedsDisplay];
        //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        //[self setNavigationBarStyle];
        //self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
        CGPoint curOffsetP = self.scrollView.contentOffset;
        [self.scrollView setContentOffset:CGPointMake(curOffsetP.x, curOffsetP.y + 0.5) animated:NO];
        //[self.scrollView setNeedsDisplay];
        //self.navigationController.navigationBar.translucent = YES;
        //self.navigationController.navigationBar.shadowImage = nil;
        //self.navigationController.view.backgroundColor = [UIColor clearColor];
        //[self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        //self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    };*/
    
    //到这里，photoItemView一定有值，而且一定显示为当前页
    //加入到当前显示中的字典
    [self.visiblePhotoItemViewDictM setObject:photoItemView forKey:@(page)];

    //传递数据
    //设置页标
    photoItemView.pageIndex = page;

    photoItemView.imageInfo = self.imageInfos[page];

    [self.scrollView addSubview:photoItemView];
    
    //    [UIView animateWithDuration:.01 animations:^{
    photoItemView.alpha=1;
    //    }];

    //这里有一个奇怪的重影bug，必须这样解决
    
    //    photoItemView.hidden=YES;
    //    [UIView animateWithDuration:.01 animations:^{
    //        photoItemView.alpha=1;
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //            photoItemView.hidden=NO;
    //        });
    //
    //    }];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Photobrowser prepare for segue");
}


-(void)singleTap{
    
    CGFloat h = _topBarView.frame.size.height;
    CGFloat bh = _bottomBarView.frame.size.height;

    BOOL show = _topBarView.tag == 0;
    
    _topBarView.tag = show ? 1 : 0;
    
    _topBarHeightC.constant = show ? -h : 0;
    //_topBarView.frame = show ? CGRectMake(0, 0, w, 64) : CGRectMake(0, 0, w, 0);
    _bottomBarHeightC.constant = show ? -bh : 0;
    [UIView animateWithDuration:.25f animations:^{
        [_topBarView setNeedsLayout];
        [_topBarView layoutIfNeeded];
        [_bottomBarView setNeedsLayout];
        [_bottomBarView layoutIfNeeded];
    }];
    
    //BOOL isHidden = [self.navigationController.navigationBar isHidden];
    //[self.navigationController setNavigationBarHidden:!isHidden animated:YES];
    //[self setNavigationBarStyle];

    /*[self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *subView, NSUInteger idx, BOOL *stop) {
        
        if([subView isKindOfClass:[PBItemView class]]){
            
            PBItemView *itemView = (PBItemView *)subView;
            
            [itemView handleBottomView];
        }
    }];*/
}




/*
 *  scrollView代理方法区
 */
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSUInteger page = [self pageCalWithScrollView:scrollView];
    
    //记录dragPage
    if(self.dragPage == 0) self.dragPage = page;
    
    self.page = page;
    
    CGFloat offsetX = scrollView.contentOffset.x;
    
    CGFloat pageOffsetX = self.dragPage * scrollView.bounds.size.width;
    
    
    if(offsetX > pageOffsetX){//正在向左滑动，展示右边的页面
        
        if(page >= self.imageInfos.count - 1) return;
        
        self.nextPage = page + 1;
        
    }else if(offsetX < pageOffsetX){//正在向右滑动，展示左边的页面
        
        if(page == 0) return;
        
        self.nextPage = page - 1;
    }
}




-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    //NSUInteger page = [self pageCalWithScrollView:scrollView];
    
    //[self reuserAndVisibleHandle:page];
}



-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    //重围
    self.dragPage = 0;
}

/*
-(void)reuserAndVisibleHandle:(NSUInteger)page{
    
    //遍历可视视图字典，除了page之外的所有视图全部移除，并加入重用集合
    [self.visiblePhotoItemViewDictM enumerateKeysAndObjectsUsingBlock:^(NSValue *key, PBItemView *photoItemView, BOOL *stop) {
        
        if(![key isEqualToValue:@(page)]){
            
            photoItemView.zoomScale=1;
            
            photoItemView.alpha=0;
            
            //[self.reusablePhotoItemViewSetM addObject:photoItemView];
            
            [self.visiblePhotoItemViewDictM removeObjectForKey:key];
        }
    }];
}*/






-(NSUInteger)pageCalWithScrollView:(UIScrollView *)scrollView{
    
    NSUInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width + .5f;
    
    return page;
}


-(void)setImageInfos:(NSMutableArray *)imageInfos {
    //NSLog(@"[PhotoBrowserViewController]setImageInfos");
    _imageInfos = imageInfos;

    //self.pageCount = imageInfos.count;
    if (_imageInfos == nil || _imageInfos.count == 0) {
        return;
    }
    __weak PBViewController *wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //初始化页码信息
        wself.page = _index;
    });
}



-(void)setPage:(NSUInteger)page{
    if (page >= self.imageInfos.count) {
        return;
    }
    PBImageInfo *curImgInfo = (PBImageInfo *)[self.imageInfos objectAtIndex:page];
    NSString *text = curImgInfo.imageTitle;
    if ([KGUtil isEmptyString:text]) {
        text = [NSString stringWithFormat:@"%@ / %@", @(page + 1) , @(self.imageInfos.count)];
    }
    /*UILabel *titleLabel = (UILabel *)self.navigationItem.titleView;
    if (titleLabel != nil) {
        titleLabel.text = text;
    }*/
    self.titleLabel.text = text;
    if (![KGUtil isEmptyString:curImgInfo.imageDesc]) {
        self.descLabel.text = curImgInfo.imageDesc;
    }
    if(_page !=0 && _page == page) return;
    
    _lastPage = page;
    
    _page = page;
    
    //设置标题
    //NSString *text = [NSString stringWithFormat:@"%@ / %@", @(page + 1) , @(self.pageCount)];
    /*PBImageInfo *curImgInfo = (PBImageInfo *)[self.imageInfos objectAtIndex:self.page];
    NSString *text = curImgInfo.imageTitle;
    if ([KGUtil isEmptyString:text]) {
        text = [NSString stringWithFormat:@"%@ / %@", @(page + 1) , @(self.imageInfos.count)];
    }
    UILabel *titleLabel = (UILabel *)self.navigationItem.titleView;
    if (titleLabel != nil) {
        titleLabel.text = text;
    }*/
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        self.topBarLabel.text = text;
//        [self.topBarLabel setNeedsLayout];
//        [self.topBarLabel layoutIfNeeded];
//    });
    __weak PBViewController *wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //显示对应的页面
        [wself showWithPage:page];
        
        //获取当前显示中的photoItemView
        wself.currentItemView = [wself.visiblePhotoItemViewDictM objectForKey:@(wself.page)];
    });
}

/** 取出可重用照片视图 */
/*-(PBItemView *)dequeReusablePhotoItemView{
    
    PBItemView *photoItemView = [self.reusablePhotoItemViewSetM anyObject];
    
    if(photoItemView != nil){
        
        //从可重用集合中移除
        [self.reusablePhotoItemViewSetM removeObject:photoItemView];
        
        [photoItemView reset];
    }
    
    return photoItemView;
}*/


/** 可重用集合 */
/*-(NSMutableSet *)reusablePhotoItemViewSetM{
    
    if(_reusablePhotoItemViewSetM ==nil){
        _reusablePhotoItemViewSetM =[NSMutableSet set];
    }
    
    return _reusablePhotoItemViewSetM;
}*/


/** 显示中视图字典 */
-(NSMutableDictionary *)visiblePhotoItemViewDictM{
    
    if(_visiblePhotoItemViewDictM == nil){
        
        _visiblePhotoItemViewDictM = [NSMutableDictionary dictionary];
    }
    
    return _visiblePhotoItemViewDictM;
}


-(void)setNextPage:(NSUInteger)nextPage{
    
    if(_nextPage == nextPage) return;
    
    _nextPage = nextPage;
    
    [self showWithPage:nextPage];
}

- (void)dismiss {
    NSLog(@"dismiss PBViewController");
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [KxMenu dismissMenu];
}
//
- (void)dealloc {
    NSLog(@"dealloc PBViewController");
}



@end
