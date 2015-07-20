//
//  GrowDoc.h
//  kindergarten
//
//  Created by ShiLiangdong on 15/7/19.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GrowDoc : NSObject

@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *docid;
@property (nonatomic, copy) NSString *picurl;
@property (nonatomic, copy) NSString *smallpicurl;
//@property (nonatomic, assign) int rating;

- (instancetype)initWithDate:(NSString *)date
                     content:(NSString *)content
                       docid:(NSString *)docid
                      picurl:(NSString *)picurl
                 smallpicurl:(NSString *)smallpicurl;

@end
