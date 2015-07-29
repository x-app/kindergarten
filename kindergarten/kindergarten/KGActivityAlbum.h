//
//  KGActivityAlbum.h
//  kindergarten
//
//  Created by wangbin on 15/7/28.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KGActivityAlbum : NSObject

@property (nonatomic, strong) NSString *dirName;
@property (nonatomic, strong) NSMutableArray *albumInfos;
@property (nonatomic) NSInteger classId;
@property (nonatomic) NSInteger dirId;
@property (nonatomic) NSInteger picCount;

@end
