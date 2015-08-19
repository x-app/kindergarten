//
//  AlbumCollectionViewController.m
//  kindergarten
//
//  Created by 庄小仙 on 15/7/28.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "AlbumCollectionViewController.h"
#import "KGUtil.h"
#import "KGConst.h"
#import "MJRefresh.h"
#import "KGActivityAlbum.h"
#import "KGActivityAlbumInfo.h"
#import "AlbumCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "PBImageInfo.h"
#import "PBViewController.h"
#import "KGPicPicker.h"
#import "GrowupEditViewController.h"
#import "PhotoCollectionViewController.h"

@interface AlbumCollectionViewController ()<UIAlertViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, KGPicPickerDelegate, KGPostImageDelegate>

@property (nonatomic) NSInteger pageIndex;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property (nonatomic) NSInteger longPressedIndex; //记录长按删除目录时的索引

@property (nonatomic) NSInteger dirIdRecord; //记录点击cell时的目录id

@property (nonatomic, strong) KGPicPicker *picPicker;      //拍照or从相册选择控件

//@property (nonatomic, strong) PBViewController *pbVC;

@property (nonatomic) NSInteger curAlbumIndex;
//@property (nonatomic, strong) NSMutableArray *imageInfos;

@end

@implementation AlbumCollectionViewController

static NSString * const reuseIdentifier = @"AlbumCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.pageIndex = 1;
    self.longPressedIndex = -1;
    self.dirIdRecord = -1;
    self.curAlbumIndex = -1;

    //[self.collectionView registerClass:[AlbumCollectionViewCell class] forCellWithReuseIdentifier:@"AlbumCell"];
    
    // 设置下拉刷新
    self.collectionView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.pageIndex = 1;
        [self loadAlbumData:YES];
    }];
    [self.collectionView.header beginRefreshing];
    
    // 设置上拉刷新
    self.collectionView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadAlbumData:NO];
    }];
    // 首次不显示
    self.collectionView.footer.hidden = YES;
    
    // 非教师时隐藏
    if (![KGUtil isTeacherVersion]) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    // Register cell classes
    //[self.collectionView registerClass:[AlbumCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (KGPicPicker *)picPicker {
    if(_picPicker == nil) {
        _picPicker = [[KGPicPicker alloc] initWithUIVC:self needCrop:FALSE multiple:YES];
        _picPicker.delegate = self;
    }
    return _picPicker;
}
/*
- (PBViewController *)pbVC {
    if (_pbVC == nil) {
        _pbVC = [[PBViewController alloc] init];
        _pbVC.handleVC = self;
        //_pbVC.imageInfos = self.imageInfos;
        if ([KGUtil isTeacherVersion]) {
            [_pbVC addAMenuItem:@"增加照片" icon:[UIImage imageNamed:@"icon_add.png"] target:self action:@selector(addPhotoToAlbumInPB:)];
            [_pbVC addAMenuItem:@"删除照片" icon:[UIImage imageNamed:@"icon_delete.png"] target:self action:@selector(deletePhotoFromAlbumInPB:)];
        } else {
            [_pbVC addAMenuItem:@"转存至成长档案" icon:[UIImage imageNamed:@"icon_add.png"] target:self action:@selector(saveToGrowupDoc:)];
        }
    }
    return _pbVC;
}*/
/*
- (NSMutableArray *)imageInfos {
    if (_imageInfos == nil) {
        _imageInfos = [[NSMutableArray alloc] init];
    }
    return _imageInfos;
}*/
/*
- (void)resetImageInfos:(NSInteger)index {
    if (index < 0 || index >= self.activityAlbums.count) {
        return;
    }
    KGActivityAlbum *curAlbum = (KGActivityAlbum *)[self.activityAlbums objectAtIndex:index];
    if (curAlbum == nil) {
        return;
    }
    [self.imageInfos removeAllObjects];
    for (int i = 0; i < [curAlbum.albumInfos count]; i++) {
        KGActivityAlbumInfo *aInfo = (KGActivityAlbumInfo *)[curAlbum.albumInfos objectAtIndex:i];
        PBImageInfo *iInfo = [[PBImageInfo alloc] init];
        iInfo.imageURL = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], aInfo.picUrl];
        iInfo.imageDesc = aInfo.desc;
        [self.imageInfos addObject:iInfo];
    }
    self.pbVC.imageInfos = self.imageInfos;
}*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (![segue.identifier isEqualToString:@"showPhotosInAlbumSegue"]) {
        return;
    }
    PhotoCollectionViewController *nextVC = (PhotoCollectionViewController *)segue.destinationViewController;
    if (nextVC == nil) {
        return;
    }
    nextVC.albumVC = self;
    AlbumCollectionViewCell *cell = (AlbumCollectionViewCell *)sender;
    if (cell == nil || cell.tag < 0 || cell.tag >= self.activityAlbums.count) {
        return;
    }
    nextVC.activityAlbum = [self.activityAlbums objectAtIndex:cell.tag];
}


#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.activityAlbums.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCollectionViewCell *cell = (AlbumCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumCell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    //cell.backgroundColor = [UIColor blackColor];
    KGActivityAlbum *curAlbum = (KGActivityAlbum *)[self.activityAlbums objectAtIndex:indexPath.row];
    cell.albumNameLabel.text = [NSString stringWithFormat:@"%@(%ld)", curAlbum.dirName, (long)curAlbum.albumInfos.count] ;
    [cell setImageViewsBorder];
    [cell prepareImageViews];
    NSString *coverUrl = [curAlbum getCoverUrl];
    //cell.album2ndImageView.image = [UIImage imageNamed:@"image_placeholder"];
    //cell.album3rdImageView.image = [UIImage imageNamed:@"image_placeholder"];

    if ([coverUrl isEqualToString:@""]) {
        cell.albumImageView.image = [UIImage imageNamed:@"camera.png"];
        cell.album2ndImageView.hidden = YES;
        cell.album3rdImageView.hidden = YES;
    } else {
        NSString *url = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], coverUrl];
        [cell.albumImageView sd_setImageWithURL:[NSURL URLWithString:url]
                               placeholderImage:[UIImage imageNamed:@"image_placeholder"]
                                        options:SDWebImageProgressiveDownload
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      }];
        if ([KGUtil isEmptyString:[curAlbum get2ndCoverUrl]]) {
            cell.album2ndImageView.hidden = YES;
            cell.album3rdImageView.hidden = YES;
        } else {
            cell.album2ndImageView.hidden = NO;
            NSString *url2nd = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], [curAlbum get2ndCoverUrl]];
            [cell.album2ndImageView sd_setImageWithURL:[NSURL URLWithString:url2nd]
                                      placeholderImage:[UIImage imageNamed:@"image_placeholder"]
                                               options:SDWebImageProgressiveDownload
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             }];
            if ([KGUtil isEmptyString:[curAlbum get3rdCoverUrl]]) {
                cell.album3rdImageView.hidden = YES;
            } else {
                cell.album3rdImageView.hidden = NO;
                NSString *url3rd = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], [curAlbum get3rdCoverUrl]];
                [cell.album3rdImageView sd_setImageWithURL:[NSURL URLWithString:url3rd]
                                          placeholderImage:[UIImage imageNamed:@"image_placeholder"]
                                                   options:SDWebImageProgressiveDownload
                                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                 }];
            }
        }
    }
    if ([KGUtil isTeacherVersion]) {
        UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCellAction:)];
        [cell addGestureRecognizer:longPressGR];
        longPressGR.minimumPressDuration = 0.7;
        longPressGR.delegate = self;
        longPressGR.view.tag = indexPath.row;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    /*if (indexPath.row >= [self.activityAlbums count] || indexPath.row < 0) {
        return;
    }
    KGActivityAlbum *curAlbum = (KGActivityAlbum *)[self.activityAlbums objectAtIndex:indexPath.row];
    if (curAlbum == nil) {
        return;
    }*/
    /*
    if (curAlbum.albumInfos && curAlbum.albumInfos.count == 0) {
        //todo 新增
        [self addPhotoToAlbum:curAlbum.dirId];
        return;
    }
    [self resetImageInfos:indexPath.row];
    self.curAlbumIndex = indexPath.row;
    self.pbVC.index = 0;
    //self.pbVC.imageInfos = self.imageInfos;
    self.pbVC.rowIndex = indexPath.row;
    self.pbVC.sectionIndex = indexPath.section;
    [self.pbVC show];
     */
}

#pragma mark UICollectionViewDelegate

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
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    /*CGFloat unitWidth = 150;
    CGFloat unitMargin = 5;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger numInARow = (int)((screenWidth - unitMargin) / (unitMargin + unitWidth));
    CGFloat realWith = (screenWidth - unitMargin) / numInARow - unitMargin;
    return CGSizeMake(realWith, realWith);*/
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    NSInteger colsNum = 3; //每行四个
    CGFloat unitMargin = 5;
    CGFloat unitWidth = (int)((screenWidth - 5 - (colsNum + 1) * unitMargin) / colsNum) ;
    return CGSizeMake(unitWidth, unitWidth + 30);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

#pragma mark methods
- (KGActivityAlbum *)getAlbum: (NSInteger)albumIndex {
    if (albumIndex < 0 || albumIndex >= self.activityAlbums.count) {
        return nil;
    }
    return self.activityAlbums[albumIndex];
}

- (KGActivityAlbumInfo *)getAlbumInfo: (NSInteger)albumIndex infoIndex:(NSInteger)infoIndex {
    if (albumIndex < 0 || albumIndex >= self.activityAlbums.count) {
        return nil;
    }
    KGActivityAlbum *curAlbum = (KGActivityAlbum *)[self.activityAlbums objectAtIndex:albumIndex];
    if (curAlbum == nil) {
        return nil;
    }
    if (infoIndex < 0 || infoIndex >= curAlbum.albumInfos.count) {
        return nil;
    }
    return [curAlbum.albumInfos objectAtIndex:infoIndex];
}


- (void)saveToGrowupDoc:(id)sender {
    if (![sender isKindOfClass:[KxMenuItem class]]) {
        return;
    }
    KxMenuItem *item = (KxMenuItem *)sender;
    NSInteger indexInPB = item.imageIndex;
    NSInteger rowInSelf = item.rowIndex;
    KGActivityAlbumInfo *info = [self getAlbumInfo:rowInSelf infoIndex:indexInPB];
    if (info == nil) {
        return;
    }
    KGActivityAlbum *album = [self getAlbum:rowInSelf];
    if (album == nil) {
        return;
    }
    NSString *desc = [KGUtil isEmptyString:info.desc] ? [NSString stringWithFormat:@"%@[%ld/%ld]", album.dirName, (long)(indexInPB + 1), (long)album.albumInfos.count]: info.desc;
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


- (void)addNewAlbumDir:(NSString *)dirName classId:(NSInteger)classId {
    NSDictionary *data = @{@"classId": @(classId),
                           @"directoryName": dirName};
    NSDictionary *body = [KGUtil getRequestBody:data];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    NSString *urlSuffix = @"/teacher/insertDirectory";
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:urlSuffix];
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            self.pageIndex = 1;
            [self loadAlbumData:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    } inView:self.collectionView showHud:NO showError:true];
}

- (void)addPhotoToAlbumInPB:(id)sender {
    if (![sender isKindOfClass:[KxMenuItem class]]) {
        return;
    }
    KxMenuItem *item = (KxMenuItem *)sender;
    NSInteger rowInSelf = item.rowIndex;
    KGActivityAlbum *album = [self getAlbum:rowInSelf];
    if (album == nil) {
        return;
    }
    [self addPhotoToAlbum:album.dirId];
}

- (void)addPhotoToAlbum:(NSInteger)dirId {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    choiceSheet.tag = dirId;
    [choiceSheet showInView:self.view];
}

- (void)deleteAlbumDir:(NSInteger)directoryId {
    NSDictionary *data = @{@"directoryId": @(directoryId)};
    NSDictionary *body = [KGUtil getRequestBody:data];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    NSString *urlSuffix = @"/teacher/deleteDirectory";
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:urlSuffix];
    UIView *tmView = [KGUtil getTopMostViewController].view;
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            self.pageIndex = 1;
            [self loadAlbumData:YES];
        } else {
            [KGUtil showCheckMark:@"删除失败" checked:NO inView:tmView];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [KGUtil showCheckMark:@"请求删除失败" checked:NO inView:tmView];
    } inView:tmView showHud:YES showError:true];
}

- (void)deletePhotoFromAlbumInPB:(id)sender {
    if (![sender isKindOfClass:[KxMenuItem class]]) {
        return;
    }
    KxMenuItem *item = (KxMenuItem *)sender;
    [self deletePhotoFromAlbum:item.sectionIndex row:item.rowIndex index:item.imageIndex isInPB:YES];
}

- (void)deletePhotoFromAlbum:(NSInteger)section row:(NSInteger)row index:(NSInteger)index isInPB:(BOOL)isInPB {
    KGActivityAlbumInfo *info = [self getAlbumInfo:row infoIndex:index];
    if (info == nil) {
        return;
    }
    [self deletePhotoFromAlbum:info.infoId index:index isInPB:isInPB];
}

- (void)deletePhotoFromAlbum:(NSInteger)activitiesAlbumInfoId index:(NSInteger)index isInPB:(BOOL)isInPB{
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
            //[self resetImageInfos:self.curAlbumIndex];
            //[self.pbVC resetAsPageRemoved];
        } else {
            [KGUtil showCheckMark:@"删除失败" checked:NO inView:view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [KGUtil showCheckMark:@"请求删除失败" checked:NO inView:view];
    } inView:view showHud:YES showError:true];
}

- (NSMutableArray *)activityAlbums {
    if (_activityAlbums == nil) {
        _activityAlbums = [[NSMutableArray alloc] init];
    }
    return _activityAlbums;
}


- (void)loadAlbumData:(BOOL)loadAll {
    NSDictionary *data = @{@"classId": @([KGUtil getCurClassId]),
                           @"pageIndex": @(self.pageIndex),
                           @"pageSize": @(10)};
    NSDictionary *body = [KGUtil getRequestBody:data];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    NSString *urlSuffix = @"/system/pageQueryDirectory";
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:urlSuffix];
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            NSDictionary *obj = [responseObject objectForKey:@"obj"];
            NSInteger pageTotalCount = [[obj objectForKey:@"pageTotalCnt"] integerValue];
            NSArray *albumArray = (NSArray *)[responseObject objectForKey:@"objlist"];
            if (loadAll == YES) {
                [self.activityAlbums removeAllObjects];
                self.activityAlbums = [[NSMutableArray alloc] initWithCapacity:[albumArray count]];;
            }
            for (int i = 0; i < albumArray.count; i++) {
                NSDictionary *curAlbum = [albumArray objectAtIndex:i];
                KGActivityAlbum *kgAlbum = [[KGActivityAlbum alloc] init];
                kgAlbum.classId = [[curAlbum objectForKey:@"classId"] integerValue];
                kgAlbum.dirId = [[curAlbum objectForKey:@"directoryId"] integerValue];
                kgAlbum.picCount = [[curAlbum objectForKey:@"picCnt"] integerValue];
                kgAlbum.dirName = [curAlbum objectForKey:@"directoryName"];
                NSArray *infoArray = [curAlbum objectForKey:@"activitiesAlbumInfos"];
                for (int j = 0; j < infoArray.count; j++) {
                    NSDictionary *curInfo = [infoArray objectAtIndex:j];
                    KGActivityAlbumInfo *kgAInfo = [[KGActivityAlbumInfo alloc] initWithId:[[curInfo objectForKey:@"activitiesAlbumInfoId"] integerValue]
                                                                                      desc:[curInfo objectForKey:@"description"]
                                                                                     dirId:[[curInfo objectForKey:@"directoryId"] integerValue]
                                                                                  smallPic:[curInfo objectForKey:@"smallPicUrl"]
                                                                                       pic:[curInfo objectForKey:@"picUrl"]];
                    [kgAlbum.albumInfos addObject:kgAInfo];
                }
                [self.activityAlbums addObject:kgAlbum];
            }
            
            [self.collectionView reloadData];
            
            self.collectionView.footer.hidden = NO;
            [self.collectionView.header endRefreshing];
            [self.collectionView.footer endRefreshing];
            if (self.activityAlbums.count < pageTotalCount) {
                self.pageIndex += 1;
            } else {
                [self.collectionView.footer noticeNoMoreData];
            }
            if (self.curAlbumIndex >= 0 && self.curAlbumIndex < self.activityAlbums.count) {
                //[self resetImageInfos:self.curAlbumIndex];
                //[self.pbVC resetToIndex:0];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self.collectionView.header endRefreshing];
        [self.collectionView.footer endRefreshing];
    } inView:self.collectionView showHud:NO showError:true];
}

- (void)dismissPhotoBrowser {
    //[self.pbVC dismiss];
}

#pragma mark actions
- (IBAction)addButtonAction:(id)sender {
    NSLog(@"add new album");
    UIAlertView *hint = [[UIAlertView alloc] initWithTitle:@"新增相册" message:@"请输入您所要新建相册的目录名" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    hint.alertViewStyle = UIAlertViewStylePlainTextInput;
    //current.nextVC = next;
    hint.tag = 0;//表示新增相册
    [hint show];
}

- (void)longPressCellAction:(id)sender {
    UIGestureRecognizer *gr = (UIGestureRecognizer *)sender;
    if (gr && gr.state == UIGestureRecognizerStateBegan) {
        NSLog(@"delete directory");
        UIAlertView *hint = [[UIAlertView alloc] initWithTitle:@"删除相册" message:@"是否确定要删除当前相册目录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        hint.tag = 1;//表示删除相册
        NSLog(@"%ld", (long)gr.view.tag);
        self.longPressedIndex = gr.view.tag;
        [hint show];
    }
}

#pragma mark -- UIAlertViewDelegate --
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    if (alertView.tag == 0) {
        if (![KGUtil isEmptyString:[alertView textFieldAtIndex:0].text]) {
            return YES;
        }
        return NO;
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"click alert view");
    if (alertView.tag == 0) {  //新增相册目录
        if (buttonIndex == 1) { //确定
            NSString *dirName = [alertView textFieldAtIndex:0].text;
            if ([KGUtil isEmptyString:dirName]) {
                [KGUtil showCheckMark:@"目录名不可为空" checked:NO inView:self.collectionView];
                return;
            }
            [self addNewAlbumDir:dirName classId:[KGUtil getCurClassId]];
        } else { //取消
            
        }
    } else if (alertView.tag == 1) { //删除相册目录
        if (buttonIndex == 0) { //确定
            if (self.longPressedIndex < 0 || self.longPressedIndex >= self.activityAlbums.count) {
                return;
            }
            KGActivityAlbum *curAlbum = (KGActivityAlbum *)[self.activityAlbums objectAtIndex:self.longPressedIndex];
            if (curAlbum) {
                NSInteger dirId = curAlbum.dirId;
                [self deleteAlbumDir:dirId];
            }
        } else { //取消
            
        }
    }
}


#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    self.dirIdRecord = actionSheet.tag;
    if (buttonIndex == 0) {
        // 拍照
        [self.picPicker takePhoto];
    } else if (buttonIndex == 1) {
        // 从相册中选取
        [self.picPicker selectPhoto];
    }
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
    vc.albumDirId = self.dirIdRecord;
    [self presentViewController:vc animated:YES
                     completion:^(void){
                     }];
}

#pragma mark - KGPostImageDelegate
- (void)reloadData {
    self.pageIndex = 1;
    [self loadAlbumData:YES];
    //[self dismissPhotoBrowser];
}

@end
