//
//  PhotoCollectionViewController.m
//  kindergarten
//
//  Created by wangbin on 15/8/11.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "PhotoCollectionViewController.h"
#import "PhotoCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "KGUtil.h"
#import "KGConst.h"
#import "KGActivityAlbumInfo.h"
#import "PBViewController.h"
#import "KGPicPicker.h"
#import "GrowupEditViewController.h"
#import "MBProgressHUD.h"

@interface PhotoCollectionViewController ()<UIActionSheetDelegate, KGPicPickerDelegate, KGPostImageDelegate>

@property (nonatomic, strong) NSMutableArray *imageInfos;  //为PhotoBrowser提供的图像信息数组

@property (nonatomic, strong) KGPicPicker *picPicker;      //拍照or从相册选择控件

@property (nonatomic, strong) PBViewController *pbVC;

@property (nonatomic) BOOL isEditing;

@property (nonatomic, strong) NSMutableArray *deleteIndexs;

// 针对多图同时删除时的一些辅助属性
@property (nonatomic) BOOL isDeleting;                //当前是否正在删除
@property (nonatomic) NSInteger deleteCount;          //总计要删除的数目
@property (nonatomic) NSInteger deleteIndex;          //当前正在删除的条目的索引
@property (nonatomic, strong) NSArray *deleteInfoIds; //待删除的相册图片的信息id
@property (nonatomic, strong) MBProgressHUD *hud;     //删除时的hud

@end

@implementation PhotoCollectionViewController

static NSString * const reuseIdentifier = @"PhotoCollectionViewCell";

//cell与cell之间的间隔
static CGFloat const unitMargin = 3;
//每行几个cell
static NSInteger const numPerRow = 4;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isEditing = NO;
    
    //self.collectionView.allowsMultipleSelection = YES;
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"PhotoCollectionView receive memory warning");
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([KGUtil isTeacherVersion]) {
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (NSMutableArray *)deleteIndexs {
    if (_deleteIndexs == nil) {
        _deleteIndexs = [[NSMutableArray alloc] init];
    }
    return _deleteIndexs;
}

- (NSArray *)deleteInfoIds {
    if (_deleteInfoIds == nil) {
        _deleteInfoIds = [[NSArray alloc] init];
    }
    return _deleteInfoIds;
}

- (MBProgressHUD *)hud {
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
        _hud.labelFont = [UIFont systemFontOfSize:13];
        _hud.removeFromSuperViewOnHide = YES;
    }
    return _hud;
}

- (KGPicPicker *)picPicker {
    if(_picPicker == nil) {
        _picPicker = [[KGPicPicker alloc] initWithUIVC:self needCrop:FALSE multiple:YES];
        _picPicker.delegate = self;
    }
    return _picPicker;
}

- (NSMutableArray *)imageInfos {
    if (_imageInfos == nil) {
        _imageInfos = [[NSMutableArray alloc] init];
    }
    return _imageInfos;
}

- (void)resetImageInfos {
    [self.imageInfos removeAllObjects];
    for (int i = 0; i < [self.activityAlbum.albumInfos count]; i++) {
        KGActivityAlbumInfo *aInfo = (KGActivityAlbumInfo *)[self.activityAlbum.albumInfos objectAtIndex:i];
        PBImageInfo *iInfo = [[PBImageInfo alloc] init];
        iInfo.imageURL = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], aInfo.picUrl];
        iInfo.imageDesc = aInfo.desc;
        [self.imageInfos addObject:iInfo];
    }
    self.pbVC.imageInfos = self.imageInfos;
}

- (PBViewController *)pbVC {
    if (_pbVC == nil) {
        _pbVC = [[PBViewController alloc] init];
        _pbVC.handleVC = self;
        _pbVC.imageInfos = self.imageInfos;
        if ([KGUtil isTeacherVersion]) {
            [_pbVC addAMenuItem:@"增加照片" icon:[UIImage imageNamed:@"icon_add.png"] target:self action:@selector(addPhotoToAlbumInPB:)];
            [_pbVC addAMenuItem:@"删除照片" icon:[UIImage imageNamed:@"icon_delete.png"] target:self action:@selector(deletePhotoFromAlbumInPB:)];
        } else {
            [_pbVC addAMenuItem:@"转存至成长档案" icon:[UIImage imageNamed:@"icon_add.png"] target:self action:@selector(saveToGrowupDoc:)];
        }
    }
    return _pbVC;
}

- (void)saveToGrowupDoc:(id)sender {
    if (![sender isKindOfClass:[KxMenuItem class]]) {
        return;
    }
    KxMenuItem *item = (KxMenuItem *)sender;
    NSInteger indexInPB = item.imageIndex;
    if (indexInPB < 0 || indexInPB >= self.activityAlbum.albumInfos.count) {
        return;
    }
    KGActivityAlbumInfo *info = [self.activityAlbum.albumInfos objectAtIndex:indexInPB];
    if (info == nil) {
        return;
    }
    NSString *desc = [KGUtil isEmptyString:info.desc] ? [NSString stringWithFormat:@"%@[%ld/%ld]", self.activityAlbum.dirName, (long)(indexInPB + 1), (long)self.activityAlbum.albumInfos.count]: info.desc;
    NSDictionary *data = @{@"childId": @([[KGUtil getCurChild] cid]),
                           @"activitiesAlbumInfoId": @(info.infoId),
                           @"description": desc};
    NSDictionary *body = [KGUtil getRequestBody:data];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    NSString *urlSuffix = @"/parent/savePicToGrowthArchive";
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:urlSuffix];
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            [KGUtil showCheckMark:@"转存成功" checked:YES inView:[KGUtil getTopMostViewController].view];
        } else {
            NSString *msg = [responseObject objectForKey:@"msg"];
            NSString *hint = [NSString stringWithFormat:@"转存失败: %@", msg];
            [KGUtil showCheckMark:hint checked:NO inView:[KGUtil getTopMostViewController].view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [KGUtil showCheckMark:@"保存至成长档案失败" checked:YES inView:self.collectionView];
    } inView:[KGUtil getTopMostViewController].view showHud:YES showError:true];
}


- (void)addPhotoToAlbumInPB:(id)sender {
    if (![sender isKindOfClass:[KxMenuItem class]]) {
        return;
    }
    [self addPhotoToAlbum];
}

- (void)addPhotoToAlbum {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    choiceSheet.tag = 1;
    [choiceSheet showInView:self.view];
}


- (void)deletePhotoFromAlbumInPB:(id)sender {
    if (![sender isKindOfClass:[KxMenuItem class]]) {
        return;
    }
    KxMenuItem *item = (KxMenuItem *)sender;
    [self deletePhotoFromAlbum:item.sectionIndex row:item.rowIndex index:item.imageIndex];
}

- (void)deletePhotoFromAlbum:(NSInteger)section row:(NSInteger)row index:(NSInteger)index {
    if (index < 0 || index >= self.activityAlbum.albumInfos.count) {
        return;
    }
    KGActivityAlbumInfo *info = [self.activityAlbum.albumInfos objectAtIndex:index];
    if (info == nil) {
        return;
    }
    [self deletePhotoFromAlbum:info.infoId];
}

- (void)deletePhotoFromAlbum:(NSInteger)activitiesAlbumInfoId {
    NSDictionary *data = @{@"activitiesAlbumInfoId": @(activitiesAlbumInfoId)};
    NSDictionary *body = [KGUtil getRequestBody:data];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    NSString *urlSuffix = @"/teacher/deleteActivitiesAlbumInfo";
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:urlSuffix];
    UIView *view = [KGUtil getTopMostViewController].view; //isInPB ? self.pbVC.view : self.collectionView;
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            [self reloadData];
            //[self resetImageInfos];
            if (self.albumVC) {
                [self.albumVC.collectionView reloadData];
            }
            [self.pbVC resetAsPageRemoved];
        } else {
            [KGUtil showCheckMark:@"删除失败" checked:NO inView:view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [KGUtil showCheckMark:@"请求删除失败" checked:NO inView:view];
    } inView:view showHud:YES showError:true];
}

- (void)deletePhotosFromAlbum:(NSArray *)infoIds {
    if (infoIds == nil || infoIds.count == 0) {
        return;
    }
    self.deleteCount = infoIds.count;
    self.deleteIndex = 0;
    self.isDeleting = YES;
    self.deleteInfoIds = infoIds;
    self.hud.labelText = @"删除中";
    [self.hud show:YES];
    [self deleteAPhotoFromAlbum:self.deleteIndex];
}

- (void)deleteAPhotoFromAlbum:(NSInteger)dIndex {
//    if (dIndex < 0 || dIndex >= self.deleteInfoIds.count) {
//        return;
//    }
    self.hud.labelText = [NSString stringWithFormat:@"正在删除%ld/%ld", (long)(dIndex + 1), (long)self.deleteCount];
    NSInteger activitiesAlbumInfoId = [[self.deleteInfoIds objectAtIndex:dIndex] integerValue];
    NSDictionary *data = @{@"activitiesAlbumInfoId": @(activitiesAlbumInfoId)};
    NSDictionary *body = [KGUtil getRequestBody:data];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    NSString *urlSuffix = @"/teacher/deleteActivitiesAlbumInfo";
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:urlSuffix];
    UIView *view = [KGUtil getTopMostViewController].view;
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            if (dIndex == self.deleteInfoIds.count - 1) { //已经删除到当前最后一张
                [self.hud hide:YES];
                [self setAllSelectedCellToUnselected];
                [self reloadData];
                //[self resetImageInfos];
                if (self.albumVC) {
                    [self.albumVC.collectionView reloadData];
                }
                [KGUtil showCheckMark:@"删除完毕" checked:YES inView:self.view];
                //[self.pbVC resetAsPageRemoved];
            } else {
                [self deleteAPhotoFromAlbum:(dIndex + 1)];
            }
        } else {
            [self deleteAPhotoFromAlbum:(dIndex + 1)];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self deleteAPhotoFromAlbum:(dIndex + 1)];
    } inView:view showHud:NO showError:NO];
}

- (void)reloadActivityAlbum {
    NSDictionary *data = @{@"directoryId": @(self.activityAlbum.dirId)};
    NSDictionary *body = [KGUtil getRequestBody:data];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    NSString *urlSuffix = @"/system/queryActivitiesAlbumInfo";
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:urlSuffix];
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            NSArray *infosArray = (NSArray *)[responseObject objectForKey:@"objlist"];
            [self.activityAlbum.albumInfos removeAllObjects];
            for (int i = 0; i < infosArray.count; i++) {
                NSDictionary *curInfo = [infosArray objectAtIndex:i];
                KGActivityAlbumInfo *kgAInfo = [[KGActivityAlbumInfo alloc] initWithId:[[curInfo objectForKey:@"activitiesAlbumInfoId"] integerValue]
                                                                                  desc:[curInfo objectForKey:@"description"]
                                                                                 dirId:[[curInfo objectForKey:@"directoryId"] integerValue]
                                                                              smallPic:[curInfo objectForKey:@"smallPicUrl"]
                                                                                   pic:[curInfo objectForKey:@"picUrl"]];
                [self.activityAlbum.albumInfos addObject:kgAInfo];
            }
            [self.collectionView reloadData];
            if (self.albumVC) {
                [self.albumVC.collectionView reloadData];
            }
            [self resetImageInfos];
            [self.pbVC resetToIndex:0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    } inView:self.collectionView showHud:NO showError:true];
}

- (NSInteger)selectedCount {
    NSArray *allRows = self.collectionView.indexPathsForVisibleItems;
    NSInteger count = 0;
    for (NSIndexPath *indexPath in allRows) {
        PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell != nil && cell.isSelected) {
            count++;
        }
    }
    return count;
}

- (void)setAllSelectedCellToUnselected {
    NSArray *allRows = self.collectionView.indexPathsForVisibleItems;
    for (NSIndexPath *selectedRow in allRows) {
        PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:selectedRow];
        if (cell == nil || cell.isSelected == NO) {
            continue;
        }
        cell.isSelected = NO;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.activityAlbum.albumInfos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell prepareImageView];
    KGActivityAlbumInfo *info = (KGActivityAlbumInfo *)[self.activityAlbum.albumInfos objectAtIndex:indexPath.row];
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:info.smallPicUrl];
    [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:url]
                           placeholderImage:[UIImage imageNamed:@"image_placeholder"]
                                    options:SDWebImageLowPriority | SDWebImageRetryFailed
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                  }];
    
//    UITapGestureRecognizer *tapPressGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCellAction:)];
//    [cell addGestureRecognizer:tapPressGR];
//    tapPressGR.view.tag = indexPath.row;
    
    PBImageInfo *iInfo = [[PBImageInfo alloc] init];
    iInfo.imageURL = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], info.picUrl];
    iInfo.imageDesc = info.desc;
    [self.imageInfos addObject:iInfo];
    
    

    // Configure the cell
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.activityAlbum.albumInfos == nil || self.activityAlbum.albumInfos.count == 0) {
        return;
    }
    //[self resetImageInfos];
    if (self.isEditing) {
//        NSArray *selectedRows = self.collectionView.indexPathsForSelectedItems;
//        for (NSIndexPath *selectedRow in selectedRows) {
//            if ((selectedRow.section == indexPath.section) && (selectedRow.row == indexPath.row)) {
//                //NSLog(@"%ld", indexPath.row);
//                //PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//                //PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)collectionView.visibleCells[indexPath.row];
//                PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//                cell.isSelected = !cell.isSelected;
//                cell.overlayImageView.hidden = !cell.isSelected;
//                //[collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
//                [collectionView reloadData];
//            }
//        }
//        NSLog(@"%ld", indexPath.row);
//        //PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//        //PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)collectionView.visibleCells[indexPath.row];
        PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.isSelected = !cell.isSelected;
        NSInteger sCount = [self selectedCount];
        self.navigationItem.title = (sCount > 0) ? [NSString stringWithFormat:@"已选择%ld张", (long)sCount] : @"选择项目";
//        //[collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
//        [collectionView reloadData];
    } else {
        self.pbVC.index = indexPath.row;
        self.pbVC.rowIndex = indexPath.row;
        self.pbVC.sectionIndex = indexPath.section;
        [self.pbVC show];
    }
    /*PBViewController *pbVC = [[PBViewController alloc] init];
    pbVC.imageInfos = self.imageInfos;
    pbVC.index = indexPath.row;
    pbVC.handleVC = self;
    pbVC.rowIndex = indexPath.row;
    pbVC.sectionIndex = indexPath.section;
    [pbVC show];*/
    
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/


#pragma mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat unitWidth = (screenWidth - (numPerRow + 1) * unitMargin) / numPerRow;
    return CGSizeMake(unitWidth, unitWidth);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return unitMargin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return unitMargin;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(unitMargin, unitMargin, unitMargin, unitMargin);
}


#pragma mark - KGPicPickerDelegate
- (void)doPicPicked:(NSArray *)images
{
    if (images == nil || images.count == 0) {
        return;
    }
    //UIImage *image = [images objectAtIndex:0];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Growup" bundle:nil];
    GrowupEditViewController *vc = (GrowupEditViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"GrowDocEdit"];
    
    vc.images = [images mutableCopy];
    vc.delegate = self;
    vc.postType = ADD_ALBUM_PHOTO;
    vc.albumDirId = self.activityAlbum.dirId;
    [self presentViewController:vc animated:YES
                     completion:^(void){
                     }];
}

#pragma mark - KGPostImageDelegate
- (void)reloadData {
    [self reloadActivityAlbum];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) { //增加相册图片
        if (buttonIndex == 0) {
            // 拍照
            [self.picPicker takePhoto];
        } else if (buttonIndex == 1) {
            // 从相册中选取
            [self.picPicker selectPhoto];
        }
    } else if (actionSheet.tag == 2) {
        NSMutableArray *infoIds = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.deleteIndexs.count; i++) {
            KGActivityAlbumInfo *info = (KGActivityAlbumInfo *)[self.activityAlbum.albumInfos objectAtIndex:i];
            if (info == nil) {
                return;
            }
            [infoIds addObject:@(info.infoId)];
        }
        [self deletePhotosFromAlbum:[infoIds copy]];
    }
}

#pragma mark actions
- (IBAction)editButtonAction:(UIBarButtonItem *)sender {
    self.isEditing = !self.isEditing;
    self.deletePhotoButton.enabled = self.isEditing;
    self.addPhotoButton.enabled = !self.isEditing;
    self.navigationItem.title = self.isEditing ? @"选择项目" : @"";
    self.editButton.title = self.isEditing ? @"取消" : @"选择";
    if (self.isEditing == NO) { //当取消编辑时，把以选中的项目取消掉
        [self setAllSelectedCellToUnselected];
    }
    self.navigationItem.hidesBackButton = self.isEditing;
}

- (IBAction)addPhotoAction:(UIBarButtonItem *)sender {
    [self addPhotoToAlbum];
}

- (IBAction)deletePhotoAction:(UIBarButtonItem *)sender {
    if (!self.isEditing) {
        return;
    }
    NSArray *allRows = self.collectionView.indexPathsForVisibleItems;
    [self.deleteIndexs removeAllObjects];
    for (NSIndexPath *indexPath in allRows) {
        PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell != nil && cell.isSelected) {
            [self.deleteIndexs addObject:@(indexPath.row)];
        }
    }
    if (self.deleteIndexs.count == 0) {
        return;
    }
    NSString *menuTitle = [NSString stringWithFormat:@"删除%ld张相片", (long)self.deleteIndexs.count];
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:menuTitle, nil];
    choiceSheet.tag = 2;
    [choiceSheet showInView:self.view];
}

//
//- (void)dealloc {
//    NSLog(@">>>>>>>>>>dealloc photo collection view");
//    _imageInfos = nil;
//    _pbVC = nil;
//}

@end
