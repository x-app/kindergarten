//
//  KGVarible.m
//  kindergarten
//
//  Created by wangbin on 15/7/14.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGVarible.h"

@implementation KGVarible

- (NSDictionary *)toDictionary {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.server_app_url, @"server_app_url",
                          self.server_index_url, @"server_index_url",
                          self.server_html_url, @"server_html_url",
                          self.parkName, @"park_name",
                          nil];
    return dict;
}

- (void)fromDictionary:(NSDictionary *)dict {
    self.server_app_url = [dict objectForKey:@"server_app_url"];
    self.server_html_url = [dict objectForKey:@"server_html_url"];
    self.server_index_url = [dict objectForKey:@"server_index_url"];
    self.parkName = [dict objectForKey:@"park_name"];
}

@end
