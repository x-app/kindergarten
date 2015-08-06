//
//  KGUIViewController.h
//  kindergarten
//
//  Created by wangbin on 15/7/11.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"

/*
typedef enum {
    bringmedic,//健康
    givemedic,//晨检
    rollcall,//点名
    parentsmess,//家长信箱
    teachermess,//教师信箱
    intopark,//进园
    holidaylist,//请假处理
    outpark,//出园
    askholiday,//请假
    bulletin,//公告
    lesson,//课程表
    birthday,//生日提醒
    cookbook,//菜谱
    masterMess,//园长信箱
    students,//班级统计
    feedback//反馈
} WebViewType;*/

@interface KGUIViewController : UIViewController

- (WebViewController*)webVC;
@property (weak, nonatomic) IBOutlet UILabel *babyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *classNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *babyPortraitImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headerBgImageView;

- (void)pushWebView:(NSString *)webViewType;

@end
