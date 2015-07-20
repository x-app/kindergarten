//
//  GrowDoc.m
//  kindergarten
//
//  Created by ShiLiangdong on 15/7/19.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "GrowDoc.h"

@implementation GrowDoc


- (instancetype)initWithDate:(NSString *)date
                     content:(NSString *)content
                       docid:(NSString *)docid
                      picurl:(NSString *)picurl
                 smallpicurl:(NSString *)smallpicurl
{
    self = [super init];
    if (self) {
        self.date = date;
        self.content = content;
        self.docid = docid;
        self.picurl = picurl;
        self.smallpicurl = smallpicurl;
    }
    return self;
}

@end
