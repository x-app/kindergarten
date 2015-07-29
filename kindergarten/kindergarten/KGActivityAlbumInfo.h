//
//  KGActivityAlbumInfo.h
//  kindergarten
//
//  Created by wangbin on 15/7/28.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KGActivityAlbumInfo : NSObject

@property (nonatomic) NSInteger infoId;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *picUrl;
@property (strong, nonatomic) NSString *smallPicUrl;
@property (nonatomic) NSInteger dirId;

-(instancetype)initWithId: (NSInteger)infoId
                     desc: (NSString *)desc
                    dirId: (NSInteger)dirId
                 smallPic: (NSString *)smallPicUrl
                      pic: (NSString *)picUrl;

@end
