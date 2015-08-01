//
//  KGVarible.h
//  kindergarten
//
//  Created by wangbin on 15/7/14.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KGVarible : NSObject

@property (nonatomic, strong) NSString *server_index_url;
@property (nonatomic, strong) NSString *server_app_url;
@property (nonatomic, strong) NSString *server_html_url;
@property (nonatomic, strong) NSString *server_push_url;

@property (nonatomic, strong) NSString *parkName;

- (NSDictionary *)toDictionary;

- (void)fromDictionary: (NSDictionary *)dict;

@end
