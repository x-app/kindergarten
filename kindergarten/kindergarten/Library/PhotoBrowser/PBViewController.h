//
//  PhotoBrowserViewController.h
//  photobrowser
//
//  Created by wangbin on 15/7/20.
//  Copyright (c) 2015年 netmad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBImageInfo.h"
#import "PBScrollView.h"
#import "PBItemView.h"
#import "KxMenu.h"


typedef enum {
    OP_ADD_PHOTO,
    OP_DELETE_PHOTO,
    OP_SAVE_TO_LOCAL,
    OP_OTHERS
} PhotoBrowserOperationType;

@interface PBViewController : UIViewController<UINavigationControllerDelegate>



/** 外部操作控制器 */
@property (nonatomic, weak) UIViewController *handleVC;

/** scrollView */
@property (weak, nonatomic) IBOutlet  PBScrollView *scrollView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewRightMarginC;

@property (nonatomic) BOOL isVisible;

@property (nonatomic) NSInteger rowIndex;
@property (nonatomic) NSInteger sectionIndex;

/** 相册数组 */
@property (nonatomic, weak) NSMutableArray *imageInfos;

/** 总页数 */
//@property (nonatomic,assign) NSUInteger pageCount;

/** page */
@property (nonatomic,assign) NSUInteger page;


/** 上一个页码 */
@property (nonatomic,assign) NSUInteger lastPage;

/** 初始显示的index */
@property (nonatomic,assign) NSUInteger index;

/** 可重用集合 */
//@property (nonatomic,strong) NSMutableSet *reusablePhotoItemViewSetM;

/** 显示中视图字典 */
@property (nonatomic,strong) NSMutableDictionary *visiblePhotoItemViewDictM;

/** 要显示的下一页 */
@property (nonatomic,assign) NSUInteger nextPage;

/** drag时的page */
@property (nonatomic,assign) NSUInteger dragPage;

/** 当前显示中的itemView */
@property (nonatomic,weak) PBItemView *currentItemView;

//是否只显示一个菜单，吧菜单图标加入pb的右上角
@property (nonatomic) BOOL showOneMenuOnly;

//- (void)removePage: (NSInteger)page;

- (void)resetAsPageRemoved;

- (void)resetToIndex: (NSInteger)index;

- (void)show;

- (void)addAMenuItem:(NSString *)title
                icon:(UIImage *)image
              target:(id)trgt
              action:(SEL)selector;

//适用于只有一个菜单项，清除其他菜单项
- (void)showMenuItem:(NSString *)title
                icon:(UIImage *)image
              target:(id)trgt
              action:(SEL)selector;

- (void)dismiss;

- (void)cleanPhotoBrowser;

@end
