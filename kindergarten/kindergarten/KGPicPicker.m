//
//  KGPicPicker.m
//  kindergarten
//
//  Created by ShiLiangdong on 15/7/26.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGPicPicker.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ELCImagePickerController.h"
@interface KGPicPicker()

@property (nonatomic, weak)UIViewController* uiVC;

@property (nonatomic) BOOL needCrop;

@property (nonatomic) BOOL multipleSelection;

@end

@implementation KGPicPicker

- (instancetype)initWithUIVC:(UIViewController *)uiVC needCrop:(BOOL)needCrop {
    self = [self init];
    return [self initWithUIVC:uiVC needCrop:needCrop multiple:NO];
}

- (instancetype)initWithUIVC:(UIViewController *)uiVC needCrop:(BOOL)needCrop multiple:(BOOL)multiple {
    self = [self init];
    if (!self) {
        return nil;
    }
    
    _uiVC = uiVC;
    _needCrop = needCrop;
    _multipleSelection = multiple;
    
    return self;
}

-(void)takePhoto
{
    if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        //            if ([self isFrontCameraAvailable]) {
        //                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        //            }
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        controller.mediaTypes = mediaTypes;
        
        controller.delegate = self;
        
        [self.uiVC presentViewController:controller
                           animated:YES
                         completion:^(void){
                             NSLog(@"Picker View Controller is presented");
                         }];
    }
}

-(void)selectPhoto
{
    if (self.multipleSelection) {
        ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
        
        elcPicker.maximumImagesCount = 100; //Set the maximum number of images to select to 100
        elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
        elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
        elcPicker.onOrder = NO; //For multiple image selection, display and return order of selected images
        elcPicker.mediaTypes = @[(NSString *)kUTTypeImage]; //Supports image and movie types, //(NSString *)kUTTypeMovie
        
        elcPicker.imagePickerDelegate = self;
        
        [self.uiVC presentViewController:elcPicker animated:YES completion:nil];
    } else {
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            
            controller.delegate = self;
            
            [self.uiVC presentViewController:controller
                                    animated:YES
                                  completion:^(void){
                                      NSLog(@"Picker View Controller is presented");
                                  }];
        }
    }
}


#pragma mark ELCImagePickerControllerDelegate Methods
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    [self.uiVC dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                [images addObject:image];
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } /*else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                
                [images addObject:image];
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else {
            NSLog(@"Uknown asset type");
        }*/
    }
    //[self finishPicPicking:images];
    [self.delegate doPicPicked:images];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    [self.uiVC dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}*/

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        
        if(self.needCrop)
        {
            // present the cropper view controller
            VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.uiVC.view.frame.size.width, self.uiVC.view.frame.size.width) limitScaleRatio:3.0];
            imgCropperVC.delegate = self;
            [self.uiVC presentViewController:imgCropperVC animated:YES completion:^{
                // TO DO
            }];
        }
        else
        {
            NSArray *images = [NSArray arrayWithObject:portraitImg];
            [self.delegate doPicPicked:images];
            //[self finishPicPicking:images];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    if (self.delegate) {
        NSArray *images = [NSArray arrayWithObject:editedImage];
        [self.delegate doPicPicked:images];
        //[self finishPicPicking:images];
    }
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}
/*
- (void)finishPicPicking:(NSArray *)images {
    if (self.delegate == nil) {
        return;
    }
    if (images == nil || images.count == 0) {
        return;
    }
    if (self.multipleSelection) {
        [self.delegate doPicPicked:images];
    } else {
        [self.delegate doPicPicked:[images objectAtIndex:0]];
    }
}*/


@end
