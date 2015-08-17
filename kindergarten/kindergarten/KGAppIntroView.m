//
//  KGAppIntroView.m
//  kindergarten
//
//  Created by wangbin on 15/8/17.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGAppIntroView.h"

@interface KGAppIntroView()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property UIView *holeView;
@property UIView *circleView;
@property UIButton *doneButton;

@end

@implementation KGAppIntroView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.bounces = NO; //最左边和最右边的时候阻止滑动
        //隐藏横向和纵向的滑动条
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.delegate = self;
        [self addSubview:self.scrollView];
        
        //底部加入一个pageControl
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height*.95, self.frame.size.width, 10)];
        //self.pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
        self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:94.0/255.0 green:183.0/255.0 blue:255.0/255.0 alpha:1.00];
        self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        [self addSubview:self.pageControl];
        
        //四个帮助界面的view
        [self createIntroViews];
        
        //跳转按钮
        self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width*.2, self.frame.size.height*.85, self.frame.size.width*.6, 40)];
        [self.doneButton setTintColor:[UIColor whiteColor]];
        NSString *title = @"立即体验";
        [self.doneButton setTitle:title forState:UIControlStateNormal];
        [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.doneButton.backgroundColor = [UIColor colorWithRed:94.0/255.0 green:183.0/255.0 blue:255.0/255.0 alpha:0.800];
        [self.doneButton addTarget:self action:@selector(onFinishedIntroButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.doneButton.layer.cornerRadius = 20;
        [self addSubview:self.doneButton];
        
        self.pageControl.numberOfPages = 4;
        self.scrollView.contentSize = CGSizeMake(self.frame.size.width*4, self.scrollView.frame.size.height);
        
        CGPoint scrollPoint = CGPointMake(0, 0);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
    return self;
}

- (void)createIntroViews {
    CGFloat frameWidth = self.frame.size.width;
    CGFloat frameHeight = self.frame.size.height;
    //help_1~help_4 四个图
    for (int i = 0; i < 4; i++) {
        UIView *view = [[UIView alloc] initWithFrame:self.frame];
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(frameWidth * i, 0, frameWidth, frameHeight)];
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        imageview.clipsToBounds = YES;
        NSString *imageName = [NSString stringWithFormat:@"help_%d.png", i + 1];
        imageview.image = [UIImage imageNamed:imageName];
        [view addSubview:imageview];
        
        [self.scrollView addSubview:view];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(self.bounds);
    CGFloat pageFraction = self.scrollView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = roundf(pageFraction);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"KGAppIntroView->scrollViewWillBeginDragging");
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"KGAppIntroView->scrollViewDidEndDecelerating");
}

#pragma mark delegate
- (void)onFinishedIntroButtonPressed:(id)sender {
    [self.delegate onDoneButtonPressed];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end