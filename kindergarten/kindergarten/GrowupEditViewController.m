//
//  GrowupEditViewController.m
//  kindergarten
//
//  Created by ShiLiangdong on 15/7/29.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "GrowupEditViewController.h"
#import "KGUtil.h"
#import "AlbumCollectionViewController.h"
#import "KGImageTableViewController.h"
#import "ImageEditCollectionViewCell.h"
#import "PBViewController.h"
#import "KGConst.h"
#import "KGPicPicker.h"

@interface GrowupEditViewController ()<UIGestureRecognizerDelegate, KGPicPickerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;

@property (nonatomic) BOOL isEditingImages;

@property (nonatomic, strong) PBViewController *pbVC;

@property (nonatomic, strong) NSMutableArray *imageInfos;

@property (nonatomic, strong) KGPicPicker *picPicker;

@end

@implementation GrowupEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(self.textView != nil)
        self.textView.delegate = self;
    
    self.isEditingImages = NO;
    
    self.imagesCollectionView.delegate = self;
    self.imagesCollectionView.dataSource = self;
    
    self.textView.text = self.placeHolderText;
    
//    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewTapAction:)];
//    tapGR.delegate = self;
//    [self.imagesCollectionView addGestureRecognizer:tapGR];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (KGPicPicker *)picPicker {
    if(_picPicker == nil) {
        _picPicker = [[KGPicPicker alloc] initWithUIVC:self needCrop:FALSE multiple:YES];
        _picPicker.delegate = self;
    }
    return _picPicker;
}

- (PBViewController *)pbVC {
    if (_pbVC == nil) {
        _pbVC = [[PBViewController alloc] init];
        _pbVC.showOneMenuOnly = YES;
        _pbVC.handleVC = self;
        [_pbVC showMenuItem:@"删除" icon:[UIImage imageNamed:@"icon_delete.png"] target:self action:@selector(deleteImageInPB:)];
    }
    return _pbVC;
}

- (NSMutableArray *)imageInfos {
    if (_imageInfos == nil) {
        _imageInfos = [[NSMutableArray alloc] init];
    }
    return _imageInfos;
}

- (void)resetImageInfos {
    [self.imageInfos removeAllObjects];
    for (int i = 0; i < [self.images count]; i++) {
        PBImageInfo *iInfo = [[PBImageInfo alloc] init];
        iInfo.image = [self.images objectAtIndex:i];
        [self.imageInfos addObject:iInfo];
    }
    self.pbVC.imageInfos = self.imageInfos;
}

- (void)deleteImage:(NSInteger)index {
    if (index < 0 || index >= self.images.count) {
        return;
    }
    [self.images removeObjectAtIndex:index];
    [self.imagesCollectionView reloadData];
    [self resetImageInfos];
    [self.pbVC resetAsPageRemoved];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onSend:(id)sender {
    [self.textView resignFirstResponder];
    NSString *attrName = @"";
    NSData* attrValue = nil;
    NSString *url = @"";
    if ([KGUtil isTeacherVersion]) {
        if (self.postType == ADD_HOMEWORK) {
            url = @"/system/insertHomework";
            attrName = @"classId";
            attrValue = [[NSString stringWithFormat:@"%ld", (long)[KGUtil getCurClassId]] dataUsingEncoding:NSUTF8StringEncoding];
        } else if (self.postType == ADD_TEACHERDESC) {
            url = @"/system/insertTeacherDesc";
            attrValue = nil;
            attrName = nil;
        } else if (self.postType == ADD_ALBUM_PHOTO) {
            url = @"/teacher/insertActivitiesAlbumInfo";
            attrName = @"directoryId";
            attrValue = [[NSString stringWithFormat:@"%ld", (long)self.albumDirId] dataUsingEncoding:NSUTF8StringEncoding];
        } else if (self.postType == ADD_CLASS_DESC) {
            url = @"/system/insertClassDesc";
            attrName = @"classId";
            attrValue = [[NSString stringWithFormat:@"%ld", (long)[KGUtil getCurClassId]] dataUsingEncoding:NSUTF8StringEncoding];
        } else if (self.postType == ADD_GARTEN_DESC) {
            url = @"/system/insertKindergartenDesc";
            attrName = nil;
            attrValue = nil;
        } else {
            return;
        }
    } else {
        if (self.postType == ADD_GROWUP_DOC) {
            url = @"/system/insertGrowthArchive";
            attrName = @"childId";
            KGChild *curchild = [KGUtil getCurChild];
            NSString *childid = [NSString stringWithFormat:@"%ld", (long)curchild.cid];
            attrValue = [childid dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            return;
        }
    }
    [KGUtil uploadImage:url
                 images:self.images
            description:self.textView.text
             customAttr:attrName
            customValue:attrValue
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSString *code = [responseObject objectForKey:@"code"];
                    if ([code isEqualToString:@"000000"]) {
                        NSLog(@"succ");
                        //reload
                        //     [self loadNewData:true];
                        [self dismissViewControllerAnimated:YES completion:^{
                            if(self.delegate)
                                [self.delegate reloadData];
                        }];
                        /*if(self.delegate)// && [self.delegate respondsToSelector:@selector(reloadData)])
                         [self.delegate reloadData];*/
                    }
                    else
                    {
                        NSString *msg = [responseObject objectForKey:@"msg"];
                        if([msg length] > 0)
                            NSLog(@"Error: %@", msg);
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                }
                 inView:self.view
                showHud:true];
}

- (IBAction)onCancel:(id)sender {
    UIAlertView *hint = [[UIAlertView alloc] initWithTitle:@"退出此次编辑？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
    hint.tag = 1;
    [hint show];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 1) { //确定退出
            [self dismissViewControllerAnimated:YES completion:nil];
        } else { //取消
            
        }
    } else if (alertView.tag == 0) {
        if (buttonIndex == 1) {
            [self deleteImage:self.pbVC.page];
        }
    }
}

#pragma mark - textview delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.text = @"";
    textView.textColor = [UIColor blackColor];

    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.location >= WORD_LIMIT)
    {
        return  NO;
    }
    else
    {
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    //该判断用于联想输入
    if (textView.text.length > WORD_LIMIT)
    {
        textView.text = [textView.text substringToIndex:WORD_LIMIT];
    }
}

#pragma mark - UICollectionViewDatasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.postType == ADD_ALBUM_PHOTO) {
        //活动相册支持多图, 仿照微信, 最后一个cell是类似于微信的增加按钮
        return (self.images.count < MAX_PHOTO_SELECTION_NUM) ? self.images.count + 1 : self.images.count;
    } else {
        return self.images.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageEditCollectionViewCell *cell = (ImageEditCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageEditCell" forIndexPath:indexPath];
    cell.imageItemView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageItemView.clipsToBounds = YES;
    if (indexPath.row == self.images.count && self.images.count < MAX_PHOTO_SELECTION_NUM) {
        cell.imageItemView.image = [UIImage imageNamed:@"icon_add_image.pngwwww"];
        cell.isAddButton = YES;
    } else {
        cell.isAddButton = NO;
        cell.imageItemView.image = [self.images objectAtIndex:indexPath.row];
    }
    //非编辑状态或者是增加按钮时，隐藏删除图标
    cell.deleteItemView.hidden = !self.isEditingImages || cell.isAddButton;
    if (self.postType == ADD_ALBUM_PHOTO) {
        UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCellAction:)];
        [cell addGestureRecognizer:longPressGR];
        longPressGR.minimumPressDuration = 0.7;
        //longPressGR.delegate = self;
        longPressGR.view.tag = indexPath.row;
        
        UITapGestureRecognizer *tapPressGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDeleteItemAction:)];
        [cell.deleteItemView addGestureRecognizer:tapPressGR];
        tapPressGR.view.tag = indexPath.row;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditingImages) {
        
    } else {
//        [self resetImageInfos];
//        self.pbVC.index = 0;
//        self.pbVC.rowIndex = indexPath.row;
//        self.pbVC.sectionIndex = indexPath.section;
//        [self.pbVC show];
        ImageEditCollectionViewCell *cell = (ImageEditCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell.isAddButton) {
            UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"取消"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"拍照", @"从相册中选取", nil];
            choiceSheet.tag = 1;
            [choiceSheet showInView:self.view];
        } else {
            self.pbVC.index = indexPath.row;
            self.pbVC.rowIndex = indexPath.row;
            self.pbVC.sectionIndex = indexPath.section;
            [self resetImageInfos];
            [self.pbVC show];
        }
    }
}

#pragma mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    NSInteger colsNum = 4; //每行四个
    CGFloat unitMargin = 5;
    CGFloat unitWidth = (int)((screenWidth - 5 - (colsNum + 1) * unitMargin) / colsNum) ;
    return CGSizeMake(unitWidth, unitWidth);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

#pragma mark 
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view != self.imagesCollectionView) {
        return NO;
    }
    return YES;
}

#pragma mark - Actions
- (void)addButtonAction:(id)sender {

}

- (void)longPressCellAction:(id)sender {
    self.isEditingImages = YES;
    [self.imagesCollectionView reloadData];
}

- (void)collectionViewTapAction:(id)sender {
    self.isEditingImages = NO;
    [self.imagesCollectionView reloadData];
}

- (void)tapDeleteItemAction:(id)sender {
    UIGestureRecognizer *gr = (UIGestureRecognizer *)sender;
    if (gr && gr.state == UIGestureRecognizerStateBegan) {
        NSLog(@"delete image");
        NSInteger imgIdx = gr.view.tag;
        [self.images removeObjectAtIndex:imgIdx];
        [self.imagesCollectionView reloadData];
    }
}

- (void)deleteImageInPB:(id)sender {
//    if (![sender isKindOfClass:[KxMenuItem class]]) {
//        return;
//    }
//    KxMenuItem *item = (KxMenuItem *)sender;
//    [self deleteImage:item.imageIndex];
    if (![sender isKindOfClass:[PBViewController class]]) {
        return;
    }

    UIAlertView *hint = [[UIAlertView alloc] initWithTitle:@"删除这张相片？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    hint.tag = 0;
    [hint show];
}

#pragma mark - KGPicPickerDelegate
- (void)doPicPicked:(NSArray *)images
{
    if (images == nil || images.count == 0) {
        return;
    }
    [self.images addObjectsFromArray:images];
    [self.imagesCollectionView reloadData];
}


#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) { //增加图片
        if (buttonIndex == 0) {
            // 拍照
            [self.picPicker takePhoto];
        } else if (buttonIndex == 1) {
            // 从相册中选取
            self.picPicker.maxNumber = MAX_PHOTO_SELECTION_NUM - self.images.count;
            [self.picPicker selectPhoto];
        }
    }
}

@end
