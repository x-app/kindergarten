//
//  PhotoBrowserViewController.h
//  photobrowser
//
//  Created by 庄小仙 on 15/7/20.
//  Copyright (c) 2015年 netmad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBImageInfo.h"
#import "PBScrollView.h"
#import "PBItemView.h"


@interface PBViewController : UIViewController



/** 外部操作控制器 */
@property (nonatomic,weak) UIViewController *handleVC;



/** scrollView */
@property (weak, nonatomic) IBOutlet  PBScrollView *scrollView;


/** 顶部条管理视图 */
@property (weak, nonatomic) IBOutlet UIView *topBarView;

/** 顶部label */
@property (weak, nonatomic) IBOutlet UILabel *topBarLabel;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBarHeightC;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewRightMarginC;




/** 相册数组 */
@property (nonatomic,strong) NSArray *imageInfos;

/** 总页数 */
@property (nonatomic,assign) NSUInteger pageCount;

/** page */
@property (nonatomic,assign) NSUInteger page;


/** 上一个页码 */
@property (nonatomic,assign) NSUInteger lastPage;


/** 初始显示的index */
@property (nonatomic,assign) NSUInteger index;


/** 可重用集合 */
@property (nonatomic,strong) NSMutableSet *reusablePhotoItemViewSetM;

/** 显示中视图字典 */
@property (nonatomic,strong) NSMutableDictionary *visiblePhotoItemViewDictM;

/** 要显示的下一页 */
@property (nonatomic,assign) NSUInteger nextPage;

/** drag时的page */
@property (nonatomic,assign) NSUInteger dragPage;

/** 当前显示中的itemView */
@property (nonatomic,weak) PBItemView *currentItemView;

-(void)show;

@end
