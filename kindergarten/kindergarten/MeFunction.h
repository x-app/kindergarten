//
//  MeFunction.h
//  kindergarten
//
//  Created by wangbin on 15/7/23.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    CHANGE_PSWD,
    SETTINGS,
    FEEDBACK,
    ABOUT,
    CLEAR_CACHE
} funcionType;

@interface MeFunction : NSObject
@property (nonatomic) funcionType type;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *cellId;
@property (nonatomic, strong) NSString *icon;
@end
