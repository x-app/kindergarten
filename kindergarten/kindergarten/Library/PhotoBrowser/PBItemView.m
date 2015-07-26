//
//  ImageBrowserItemView.m
//
//  Created by wangbin on 15/7/20.
//  Copyright (c) 2015年 netmad. All rights reserved.
//

#import "PBItemView.h"
#import "UIImageView+WebCache.h"
#import "PBProgressView.h"
@interface PBItemView ()<UIScrollViewDelegate>{
    CGFloat _zoomScale;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet PBProgressView *progressView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMarginC;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightMarginC;

@property (weak, nonatomic) IBOutlet UIView *bgView;



/** view的单击 */
@property (nonatomic,strong) UITapGestureRecognizer *tap_single_viewGesture;

/** view的单击 */
@property (nonatomic,strong) UITapGestureRecognizer *tap_double_viewGesture;

/** imageView的双击 */
@property (nonatomic,strong) UITapGestureRecognizer *tap_double_imageViewGesture;











/** 双击放大 */
@property (nonatomic,assign) BOOL isDoubleClickZoom;


@end


@implementation PBItemView



-(void)awakeFromNib {
    
    [super awakeFromNib];
    
    //数据准备
    [self dataPrepare];
    
    //添加手势
    [self addGestureRecognizer:self.tap_single_viewGesture];
    [self addGestureRecognizer:self.tap_double_viewGesture];
    [self addGestureRecognizer:self.tap_double_imageViewGesture];
}

-(void)setImageInfo:(PBImageInfo *)imageInfo {
    _imageInfo = imageInfo;
    if (imageInfo == nil) return;
    [self dataPrepare];
}


/*
 *  数据准备
 */
-(void)dataPrepare{
    
    if(self.imageInfo == nil) return;
    
    //创建imageView
    //UIImage *img_placeholder = [UIImage imageNamed:@"PBResource.bundle/empty_picture"];
    //UIImage *image = [self remakeImageWithFullSize:img_placeholder size:[UIScreen mainScreen].bounds.size zoom:0.3f];
    
    //self.photoImageView.image = image;
    
    //if(image == nil) return;
    
    /*[self.photoImageView imageWithUrlStr:_photoModel.image_HD_U phImage:image progressBlock:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        _progressView.hidden = NO;
        
        CGFloat progress = receivedSize /((CGFloat)expectedSize);
        
        _progressView.progress = progress;
        
    } completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        self.hasImage = image !=nil;
        
        if(image!=nil && _progressView.progress <1.0f) {
            _progressView.progress = 1.0f;
        }
    }];*/
    
    //__block UIActivityIndicatorView *activityIndicator;
    __block CGRect windowFrame = [[UIScreen mainScreen] bounds];
    CGRect placeholderFrame = CGRectMake(windowFrame.size.width / 2 - 50, windowFrame.size.height / 2 - 50, 100, 100);
    self.photoImageView.frame = placeholderFrame;
    //__weak UIImageView *weakImageView = self.photoImageView;
    [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:self.imageInfo.imageURL]
                      //placeholderImage:[UIImage imageNamed:@"PBResource.bundle/empty_picture"]
                        placeholderImage:self.imageInfo.placeHolder
                               options:SDWebImageLowPriority | SDWebImageRetryFailed//SDWebImageProgressiveDownload
                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  //self.photoImageView.frame = placeholderFrame;
                                  NSLog(@">>>>%f", (double)receivedSize/expectedSize);
                                  /*if (!activityIndicator) {
                                      activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                                      [weakImageView addSubview:activityIndicator];
                                      activityIndicator.center = CGPointMake(50.0, 50.0);//CGPointMake(windowFrame.size.width / 2.0, windowFrame.size.height / 2.0);
                                      //activityIndicator.center = weakImageView.center;
                                      [activityIndicator startAnimating];
                                  }*/
                                  _progressView.hidden = NO;
                                  
                                  CGFloat progress = receivedSize /((CGFloat)expectedSize);
                                  
                                  _progressView.progress = progress;
                              }
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 self.photoImageView.frame = windowFrame;

                                 NSLog(@"load image compelted");
                                 //[activityIndicator removeFromSuperview];
                                 //activityIndicator = nil;
                                 if(image!=nil && _progressView.progress <1.0f) {
                                     _progressView.progress = 1.0f;
                                 }
                                 self.hasImage = image !=nil;
                             }];
    
    
    
    self.scrollView.contentSize = self.photoImageView.frame.size;
    
    
    //self.photoImageView.frame = self.imageInfo.sourceFrame;

    //self.photoImageView.frame = [[UIScreen mainScreen] bounds]; //self.photoImageView.calF;
    
    
    //标题
    //_titleLabel.text = self.imageInfo.imageTitle;
    _descLabel.text = self.imageInfo.imageDesc;
}

-(UIImage *)remakeImageWithFullSize:(UIImage *)image size:(CGSize)fullSize zoom:(CGFloat)zoom{
    
    //新建上下文
    UIGraphicsBeginImageContextWithOptions(fullSize, NO, 0.0);
    
    //图片原本size
    CGSize size_orignal = image.size;
    CGFloat sizeW = size_orignal.width * zoom;
    CGFloat sizeH = size_orignal.height * zoom;
    CGFloat x = (fullSize.width - sizeW) *.5f;
    CGFloat y = (fullSize.height - sizeH) * .5f;
    CGRect rect = CGRectMake(x, y, sizeW, sizeH);
    
    [image drawInRect:rect];
    
    //获取图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //结束上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}


-(PBImageView *)photoImageView{
    
    if(_photoImageView == nil){
        
        _photoImageView = [[PBImageView alloc] init];
        
        _photoImageView.userInteractionEnabled = YES;
        
        [self.scrollView addSubview:_photoImageView];
    }
    
    return _photoImageView;
}








/*
 *  事件处理
 */
/*
 *  view单击
 */
-(void)tap_single_viewTap:(UITapGestureRecognizer *)tap{
    [self tap_view];
}

/*
 *  view双击
 */
-(void)tap_double_viewTap:(UITapGestureRecognizer *)tap{
    [self tap_view];
}

-(void)tap_view{
    if(_ItemViewSingleTapBlock != nil) _ItemViewSingleTapBlock();
}


/*
 *  imageView双击
 */
-(void)tap_double_imageViewTap:(UITapGestureRecognizer *)tap{
    
    if(!self.hasImage) return;
    
    //标记
    self.isDoubleClickZoom = YES;
    
    CGFloat zoomScale = self.scrollView.zoomScale;
    
    if(zoomScale<=1.0f){
        
        CGPoint loc = [tap locationInView:tap.view];
        
        CGFloat wh =1;
        
        CGFloat x = loc.x - wh *.5f;
        CGFloat y = loc.y - wh * .5f;
        CGRect rect = (CGRect){CGPointMake(x, y),CGSizeMake(wh, wh)};
        
        
        [self.scrollView zoomToRect:rect animated:YES];
    }else{
        [self.scrollView setZoomScale:1.0f animated:YES];
    }
}




//
//
//
///*
// *  旋转手势
// */
//-(void)rota:(UIRotationGestureRecognizer *)rotaGesture{
//    
//    NSLog(@"旋转");
//    self.photoImageView.transform = CGAffineTransformRotate(rotaGesture.view.transform, rotaGesture.rotation);
//    rotaGesture.rotation = 0;
//}





/*
 *  处理bottomView
 */
-(void)handleBotoomView{
    
    CGFloat h = _bottomView.frame.size.height;
    
    BOOL show = _bottomView.tag == 0;
    
    _bottomView.tag = show?1:0;
    
    _bottomMarginC.constant = show?-h:0;
    
    [UIView animateWithDuration:.25f animations:^{
        
        [_bottomView setNeedsLayout];
        [_bottomView layoutIfNeeded];
    }];
    
}









/*
 *  代理方法区
 */
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return self.photoImageView;
}





-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    if(scrollView.zoomScale <=1) scrollView.zoomScale = 1.0f;
    
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    
    [self.photoImageView setCenter:CGPointMake(xcenter, ycenter)];
}



/** 懒加载 */

/*
 *  view单击
 */
-(UITapGestureRecognizer *)tap_single_viewGesture{
    
    if(_tap_single_viewGesture == nil){
        
        _tap_single_viewGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_single_viewTap:)];
        [_tap_single_viewGesture requireGestureRecognizerToFail:self.tap_double_imageViewGesture];
        [_tap_single_viewGesture requireGestureRecognizerToFail:self.tap_double_viewGesture];
    }
    
    return _tap_single_viewGesture;
}




/*
 *  view双击
 */
-(UITapGestureRecognizer *)tap_double_viewGesture{
    
    if(_tap_double_viewGesture == nil){
        
        _tap_double_viewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_double_viewTap:)];
        [_tap_double_viewGesture requireGestureRecognizerToFail:self.tap_double_imageViewGesture];
        _tap_double_viewGesture.numberOfTapsRequired = 2;
    }
    
    return _tap_double_viewGesture;
}





/*
 *  imageView单击
 */
-(UITapGestureRecognizer *)tap_double_imageViewGesture{
    
    if(_tap_double_imageViewGesture == nil){
        
        _tap_double_imageViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_double_imageViewTap:)];
        _tap_double_imageViewGesture.numberOfTapsRequired = 2;
    }
    
    return _tap_double_imageViewGesture;
}



/*
 *  保存图片及回调
 */
-(void)save:(void(^)())ItemImageSaveCompleteBlock failBlock:(void(^)())failBlock{
    
    if(self.photoImageView.image == nil){
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(failBlock != nil) failBlock();
        });
        return;
    }
    
    //[self.photoImageView.image savedPhotosAlbum:ItemImageSaveCompleteBlock failBlock:failBlock];
}


/*
 *  重置
 */
-(void)reset{
    
    //缩放比例
    self.scrollView.zoomScale = 1.0f;
    
    //默认无图
    self.hasImage = NO;
    self.photoImageView.frame=CGRectZero;
}


-(CGRect)itemImageViewFrame{
    
    return self.photoImageView.frame;
}

/*
-(void)zoomDismiss:(void(^)())compeletionBlock{
    
    //隐藏图片
    //self.imageInfo.sourceImageView.hidden = YES;
    
    [UIView animateWithDuration:.4f animations:^{
        
        self.bgView.alpha=0;
        
        self.bottomView.alpha=0;
    }];
    
    
    [UIView animateWithDuration:.5f delay:0 usingSpringWithDamping:.6f initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.photoImageView.contentMode = self.photoModel.sourceImageView.contentMode;
        self.photoImageView.frame = self.photoModel.sourceFrame;
        self.photoImageView.clipsToBounds = YES;
    } completion:^(BOOL finished) {
        
        //显示图片
        self.photoModel.sourceImageView.hidden = NO;
        
        if(finished && compeletionBlock!=nil) compeletionBlock();
    }];
}*/



//
//
//-(CGFloat)zoomScale{
//    return self.scrollView.zoomScale;
//}

-(void)setZoomScale:(CGFloat)zoomScale{
    _zoomScale = zoomScale;
    [self.scrollView setZoomScale:zoomScale animated:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
