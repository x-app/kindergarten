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

@end

const CGFloat segWidth = 20.f;

@implementation PBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self vcPrepare];
    self.navigationController.delegate = self;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0 , 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
    titleLabel.font = [UIFont boldSystemFontOfSize:12];  //设置文本字体与大小
    titleLabel.textColor = [UIColor whiteColor];  //设置文本颜色
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"";
    self.navigationItem.titleView = titleLabel;
    
    self.scrollView.backgroundColor = [UIColor blackColor];
    
    [self.menuItems addObject:[KxMenuItem menuItem:@"保存至本地相册"
                                             image:[UIImage imageNamed:@"save.png"]
                                            target:self
                                            action:@selector(saveImageToLocalAlbum:)]];
    // Do any additional setup after loading the view.
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/** 真正展示 */
-(void)show{
    [self pagesPrepare];
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
    [self cleanPhotoBrowser];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self pagesPrepare];
    [self setNavigationBarStyle];
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //NSLog(@"in delegate!");
    if (viewController == self) {
        UIImage *rightImage = [UIImage imageNamed:@"gallery_more_icon.png"];
        UIImageView *rightImageView = [[UIImageView alloc] initWithImage:rightImage];
        rightImageView.contentMode = UIViewContentModeScaleAspectFill;
        rightImageView.frame = CGRectMake(5, 0, 10, 20);
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [rightButton addTarget:self action:@selector(clickRightButton:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton addSubview:rightImageView];
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = rightButtonItem;
        
        //UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStyleDone target:self action:@selector(backBtnAction:)];
       // UIBarButtonItem *backItem2 = [UIBarButtonItem alloc] initwith
        //self.navigationItem.leftBarButtonItem = backItem;
        //self.navigationItem.leftBarButtonItem.target = self;
        //[self.navigationItem.leftBarButtonItem respondsToSelector:@selector(backBtnAction:)];
        //[_handleVC.navigationItem setBackBarButtonItem:backItem];
        [self setNavigationBarStyle];
    } else {
        [self restoreNavigationBarStyle];
    }
}

- (void)cleanPhotoBrowser {
    for (int i = 0; i < self.scrollView.subviews.count; i++) {
        UIView *view = [self.scrollView.subviews objectAtIndex:i];
        [view removeFromSuperview];
    }
    //[self.reusablePhotoItemViewSetM removeAllObjects];
    [self.visiblePhotoItemViewDictM removeAllObjects];
}

- (void)clickRightButton:(UIButton *)sender {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect rect = CGRectMake(screenBounds.size.width - 80, self.navigationController.navigationBar.frame.origin.y, 100, self.navigationController.navigationBar.frame.size.height);
    for (int i = 0; i < _menuItems.count; i++) {
        KxMenuItem *item = (KxMenuItem *)[_menuItems objectAtIndex:i];
        item.imageIndex = self.page;
        item.rowIndex = self.rowIndex;
        item.sectionIndex = self.sectionIndex;
    }
    [KxMenu showMenuInView:self.view
                  fromRect:rect//self.navigationController.navigationBar.frame// self..frame
                 menuItems:self.menuItems];
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
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    //self.navigationItem.leftBarButtonItem.tintColor = [UIColor redColor];
}

- (void)restoreNavigationBarStyle {
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
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
-(void)pagesPrepare{
    if (self.imageInfos == nil || self.imageInfos.count == 0) {
        return;
    }
    __block CGRect frame = [UIScreen mainScreen].bounds;
    
    CGFloat widthEachPage = frame.size.width + segWidth;
    
    //[self.reusablePhotoItemViewSetM removeAllObjects];
    //[self.visiblePhotoItemViewDictM removeAllObjects];
    
    //展示页码对应的页面
    [self showWithPage:self.index];
    //self.page = self.index;
    //设置contentSize
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
    if (self.imageInfos == nil || self.imageInfos.count == 0) {
        [self dismiss];
    }
    [self cleanPhotoBrowser];
    self.index = index;
    [self pagesPrepare];
}
/*
- (void)removePage: (NSInteger)page {
    if (page < 0 || page >= self.imageInfos.count) {
        return;
    }
    NSInteger nextPage = -1;
    if (page == 0 && self.imageInfos.count == 1) {
        //nextPage = 0;
        [self dismiss];
        return;
    } else {
        nextPage = (page == self.imageInfos.count - 1) ? self.imageInfos.count - 2 : page;
    }
    //[self showWithPage:nextPage];
    //[self setPage:nextPage];
    
    //CGRect targetFrame = CGRectMake(-320, 0, 320, 568);
    //self.scrollView.pagingEnabled = YES;
    //CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    //CGPoint targetPoint = CGPointMake((screenWidth + segWidth) * nextPage, 0);
    //[self.scrollView setContentOffset:targetPoint animated:YES];
    //[self.imageInfos removeObjectAtIndex:page];
    [self.imageInfos removeObjectAtIndex:page];
    //self.pageCount = self.imageInfos.count;
//    for (int i = 0; i < self.scrollView.subviews.count; i++) {
//        UIView *view = [self.scrollView.subviews objectAtIndex:i];
//        [view removeFromSuperview];
//    }
    [self.currentItemView removeFromSuperview];
    //[self.visiblePhotoItemViewDictM removeObjectForKey:@(page)];
    if (self.currentItemView) {
        [self.reusablePhotoItemViewSetM removeObject:self.currentItemView];
    }
    if ([[self.visiblePhotoItemViewDictM allKeys] containsObject:@(page)]) {
        [self.visiblePhotoItemViewDictM removeObjectForKey:@(page)];
    }
    //[self.reusablePhotoItemViewSetM removeAllObjects];
    //[self.visiblePhotoItemViewDictM removeAllObjects];
    self.index = nextPage;
    self.page = nextPage;
    [self pagesPrepare];
    //[self showWithPage:nextPage];


    //[self pagesPrepare];
    //[_currentItemView removeFromSuperview];
    //[self.scrollView setContentOffset:targetPoint animated:YES];
    //self.page = nextPage;
    //[self.scrollView scrollRectToVisible:targetFrame animated:YES];
    //[self.scrollView scrollRectToVisible:CGRectMake(320 * nextPage, 0, 320, 568) animated:YES];
    //[self.imageInfos removeObjectAtIndex:page];
}*/

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
    NSLog(@"%p",&photoItemView);
    
    //数据覆盖
    photoItemView.ItemViewSingleTapBlock = ^(){
        [self singleTap];
    };
    
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




-(void)singleTap{
    
    /*CGFloat h = _topBarView.frame.size.height;
    
    BOOL show = _topBarView.tag == 0;
    
    _topBarView.tag = show?1:0;
    
    _topBarHeightC.constant = show?-h:0;
    
    [UIView animateWithDuration:.25f animations:^{
        
        [_topBarView setNeedsLayout];
        [_topBarView layoutIfNeeded];
    }];*/
    BOOL isHidden = [self.navigationController.navigationBar isHidden];
    [self.navigationController setNavigationBarHidden:!isHidden animated:YES];
    [self setNavigationBarStyle];
    
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *subView, NSUInteger idx, BOOL *stop) {
        
        if([subView isKindOfClass:[PBItemView class]]){
            
            PBItemView *itemView = (PBItemView *)subView;
            
            [itemView handleBottomView];
        }
    }];
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
    NSLog(@"[PhotoBrowserViewController]setImageInfos");
    _imageInfos = imageInfos;
    
    //self.pageCount = imageInfos.count;
    if (_imageInfos == nil || self.imageInfos.count == 0) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //初始化页码信息
        self.page = _index;
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
    UILabel *titleLabel = (UILabel *)self.navigationItem.titleView;
    if (titleLabel != nil) {
        titleLabel.text = text;
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //显示对应的页面
        [self showWithPage:page];
        
        //获取当前显示中的photoItemView
        self.currentItemView = [self.visiblePhotoItemViewDictM objectForKey:@(self.page)];
    });
}






-(UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleLightContent;
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
    [self.navigationController popViewControllerAnimated:YES];
}



@end
