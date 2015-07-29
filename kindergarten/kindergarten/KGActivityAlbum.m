//
//  KGActivityAlbum.m
//  kindergarten
//
//  Created by wangbin on 15/7/28.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGActivityAlbum.h"
#import "KGActivityAlbumInfo.h"
@implementation KGActivityAlbum


- (NSMutableArray *)albumInfos {
    if (_albumInfos == nil) {
        _albumInfos = [[NSMutableArray alloc] init];
    }
    return _albumInfos;
}

- (NSString *)getCoverUrl {
    if (self.albumInfos.count == 0) {
        return @"";
    } else {
        KGActivityAlbumInfo *info = (KGActivityAlbumInfo *)[self.albumInfos objectAtIndex:0];
        if (info != nil) {
            return info.smallPicUrl;
        } else {
            return @"";
        }
    }
}

@end
