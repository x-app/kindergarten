//
//  KGActivityAlbumInfo.m
//  kindergarten
//
//  Created by wangbin on 15/7/28.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGActivityAlbumInfo.h"

@implementation KGActivityAlbumInfo

-(instancetype)initWithId: (NSInteger)infoId
                     desc: (NSString *)desc
                    dirId: (NSInteger)dirId
                 smallPic: (NSString *)smallPicUrl
                      pic: (NSString *)picUrl {
    self = [super init];
    if (self) {
        self.infoId = infoId;
        self.desc = desc;
        self.dirId = dirId;
        self.smallPicUrl = smallPicUrl;
        self.picUrl = picUrl;
    }
    return self;
}

@end
