//
//  KGActivityAlbum.m
//  kindergarten
//
//  Created by wangbin on 15/7/28.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGActivityAlbum.h"

@implementation KGActivityAlbum


- (NSMutableArray *)albumInfos {
    if (_albumInfos == nil) {
        _albumInfos = [[NSMutableArray alloc] init];
    }
    return _albumInfos;
}

@end
