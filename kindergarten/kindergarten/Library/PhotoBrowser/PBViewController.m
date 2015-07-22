//
//  PhotoBrowserViewController.m
//  photobrowser
//
//  Created by 庄小仙 on 15/7/20.
//  Copyright (c) 2015年 netmad. All rights reserved.
//

#import "PBViewController.h"


@interface PBViewController ()<UIScrollViewDelegate>


@end

@implementation PBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self vcPrepare];
    self.navigationController.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


/** 真正展示 */
-(void)show{
    [self pushPhotoVC];
}


/** push */
-(void)pushPhotoVC{
    [_handleVC.navigationController pushViewController:self animated:YES];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNavigationBarStyle];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
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
    _scrollViewRightMarginC.constant = - 20.f;
}



/** 每页准备 */
-(void)pagesPrepare{
    
    __block CGRect frame = [UIScreen mainScreen].bounds;
    
    CGFloat widthEachPage = frame.size.width + 20.0f;
    
    //展示页码对应的页面
    [self showWithPage:self.index];
    
    //设置contentSize
    self.scrollView.contentSize = CGSizeMake(widthEachPage * self.imageInfos.count, 0);
    
    self.scrollView.index = _index;
}



/*
 *  展示页码对应的页面
 */
-(void)showWithPage:(NSUInteger)page{
    
    //如果对应页码对应的视图正在显示中，就不用再显示了
    if([self.visiblePhotoItemViewDictM objectForKey:@(page)] != nil) return;
    
    //取出重用photoItemView
    PBItemView *photoItemView = [self dequeReusablePhotoItemView];
    
    if(photoItemView == nil){//没有取到
        
        //重新创建
        photoItemView = [[[NSBundle mainBundle] loadNibNamed:@"PBItemView" owner:nil options:nil] firstObject];
    }
    
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
            
            [itemView handleBotoomView];
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
        
        if(page >= self.pageCount - 1) return;
        
        self.nextPage = page + 1;
        
    }else if(offsetX < pageOffsetX){//正在向右滑动，展示左边的页面
        
        if(page == 0) return;
        
        self.nextPage = page - 1;
    }
}




-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    NSUInteger page = [self pageCalWithScrollView:scrollView];
    
    [self reuserAndVisibleHandle:page];
}



-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    //重围
    self.dragPage = 0;
}



-(void)reuserAndVisibleHandle:(NSUInteger)page{
    
    //遍历可视视图字典，除了page之外的所有视图全部移除，并加入重用集合
    [self.visiblePhotoItemViewDictM enumerateKeysAndObjectsUsingBlock:^(NSValue *key, PBItemView *photoItemView, BOOL *stop) {
        
        if(![key isEqualToValue:@(page)]){
            
            photoItemView.zoomScale=1;
            
            photoItemView.alpha=0;
            
            [self.reusablePhotoItemViewSetM addObject:photoItemView];
            
            [self.visiblePhotoItemViewDictM removeObjectForKey:key];
        }
    }];
}






-(NSUInteger)pageCalWithScrollView:(UIScrollView *)scrollView{
    
    NSUInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width + .5f;
    
    return page;
}


-(void)setImageInfos:(NSArray *)imageInfos {
    NSLog(@"[PhotoBrowserViewController]setImageInfos");
    _imageInfos = imageInfos;
    
    self.pageCount = imageInfos.count;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //初始化页码信息
        self.page = _index;
    });
}



-(void)setPage:(NSUInteger)page{
    
    if(_page !=0 && _page == page) return;
    
    _lastPage = page;
    
    _page = page;
    
    //设置标题
    //NSString *text = [NSString stringWithFormat:@"%@ / %@", @(page + 1) , @(self.pageCount)];
    PBImageInfo *curImgInfo = (PBImageInfo *)[self.imageInfos objectAtIndex:self.page];
    NSString *text = curImgInfo.imageTitle;
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
-(PBItemView *)dequeReusablePhotoItemView{
    
    PBItemView *photoItemView = [self.reusablePhotoItemViewSetM anyObject];
    
    if(photoItemView != nil){
        
        //从可重用集合中移除
        [self.reusablePhotoItemViewSetM removeObject:photoItemView];
        
        [photoItemView reset];
    }
    
    return photoItemView;
}





/** 可重用集合 */
-(NSMutableSet *)reusablePhotoItemViewSetM{
    
    if(_reusablePhotoItemViewSetM ==nil){
        _reusablePhotoItemViewSetM =[NSMutableSet set];
    }
    
    return _reusablePhotoItemViewSetM;
}


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

- (IBAction)backBtnAction:(UIButton *)sender {
    [self dismiss];
}


//
-(void)dismiss{
    [self.navigationController popViewControllerAnimated:YES];
}



@end
