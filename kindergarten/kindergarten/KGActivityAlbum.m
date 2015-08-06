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
    }
    return [self getPhotoUrl:0];
}

- (NSString *)get2ndCoverUrl {
    return [self getPhotoUrl:1];
}

- (NSString *)get3rdCoverUrl {
    return [self getPhotoUrl:2];
}

- (NSString *)getPhotoUrl: (NSInteger)index {
    if (index < 0 || index >= self.albumInfos.count) {
        return @"";
    }
    KGActivityAlbumInfo *info = (KGActivityAlbumInfo *)[self.albumInfos objectAtIndex:index];
    if (info != nil) {
        return info.smallPicUrl;
    } else {
        return @"";
    }
}
@end
