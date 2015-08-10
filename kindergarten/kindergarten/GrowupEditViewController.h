//
//  GrowupEditViewController.h
//  kindergarten
//
//  Created by ShiLiangdong on 15/7/29.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ADD_GROWUP_DOC,    //增加成长档案
    ADD_HOMEWORK,      //增加作业
    ADD_TEACHERDESC,   //增加教师风采
    ADD_CLASS_DESC,    //增加班级介绍
    ADD_GARTEN_DESC,   //增加园区介绍
    ADD_ALBUM_PHOTO    //活动相册新增照片
} KG_POST_TYPE;

@protocol KGPostImageDelegate

-(void)reloadData;

@end

@interface GrowupEditViewController : UIViewController <UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) id<KGPostImageDelegate> delegate;

@property (nonatomic) KG_POST_TYPE postType;

@property (nonatomic, strong)NSString *placeHolderText;

@property (nonatomic) NSInteger albumDirId; //用于传递活动相册目录id

@property (nonatomic, strong) NSMutableArray *images;

@end
