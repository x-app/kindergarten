//
//  KGImageTableRowInfo.h
//  kindergarten
//
//  Created by wangbin on 15/8/4.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface KGImageTableRowInfo : NSObject

@property (strong, nonatomic) NSString *picUrl;
@property (strong, nonatomic) NSString *smallPicUrl;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *createTime;

@property (strong, nonatomic) UIImage *coverImage;

- (instancetype)initWithDesc: (NSString *)desc
                      picUrl: (NSString *)picUrl
                 smallPicUrl: (NSString *)smallPicUrl
                    createAt: (NSString *)createTime;
@end
