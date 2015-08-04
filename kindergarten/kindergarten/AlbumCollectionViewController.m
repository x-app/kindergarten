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

@interface AlbumCollectionViewController ()<UIAlertViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, KGPicPickerDelegate, KGPostImageDelegate>

@property (nonatomic) NSInteger pageIndex;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property (nonatomic) NSInteger longPressedIndex; //记录长按删除目录时的索引

@property (nonatomic) NSInteger dirIdRecord; //记录点击cell时的目录id

@property (nonatomic, strong) KGPicPicker *picPicker;      //拍照or从相册选择控件

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

    //[self.collectionView registerClass:[AlbumCollectionViewCell class] forCellWithReuseIdentifier:@"AlbumCell"];
    
    // 设置下拉刷新
    self.collectionView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
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
        _picPicker = [[KGPicPicker alloc] initWithUIVC:self needCrop:FALSE];
        _picPicker.delegate = self;
    }
    return _picPicker;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.activityAlbums.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCollectionViewCell *cell = (AlbumCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumCell" forIndexPath:indexPath];
    //cell.backgroundColor = [UIColor blackColor];
    KGActivityAlbum *curAlbum = (KGActivityAlbum *)[self.activityAlbums objectAtIndex:indexPath.row];
    cell.albumNameLabel.text = [NSString stringWithFormat:@"%@(%ld)", curAlbum.dirName, (long)curAlbum.albumInfos.count] ;
    cell.albumImageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.albumImageView.clipsToBounds = YES;
    NSString *coverUrl = [curAlbum getCoverUrl];
    if ([coverUrl isEqualToString:@""]) {
        cell.albumImageView.image = [UIImage imageNamed:@"image_placeholder"];
    } else {
        NSString *url = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], coverUrl];
        [cell.albumImageView sd_setImageWithURL:[NSURL URLWithString:url]
                               placeholderImage:[UIImage imageNamed:@"image_placeholder"]
                                        options:SDWebImageProgressiveDownload
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      }];
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
    if (indexPath.row >= [self.activityAlbums count] || indexPath.row < 0) {
        return;
    }
    KGActivityAlbum *curAlbum = (KGActivityAlbum *)[self.activityAlbums objectAtIndex:indexPath.row];
    if (curAlbum == nil) {
        return;
    }
    if (curAlbum.albumInfos && curAlbum.albumInfos.count == 0) {
        //todo 新增
        [self addPhotoToAlbum:curAlbum.dirId];
        return;
    }
    NSMutableArray *imageInfos = [[NSMutableArray alloc] initWithCapacity:[curAlbum.albumInfos count]];
    for (int i = 0; i < [curAlbum.albumInfos count]; i++) {
        KGActivityAlbumInfo *aInfo = (KGActivityAlbumInfo *)[curAlbum.albumInfos objectAtIndex:i];
        PBImageInfo *iInfo = [[PBImageInfo alloc] init];
        iInfo.imageURL = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], aInfo.picUrl];
        //iInfo.imageTitle = [NSString stringWithFormat:@"%ld/%ld", (long)(i + 1), (long)curAlbum.albumInfos.count];
        iInfo.imageDesc = aInfo.desc;
        [imageInfos addObject:iInfo];
    }
    PBViewController *pbVC = [[PBViewController alloc] init];
    pbVC.index = 0;
    pbVC.handleVC = self;
    pbVC.rowIndex = indexPath.row;
    pbVC.sectionIndex = indexPath.section;
    pbVC.imageInfos = imageInfos;
    [pbVC addAMenuItem:@"转存至成长档案" icon:[UIImage imageNamed:@"baby_icon_normal.png"] target:self action:@selector(saveToGrowupDoc:)];
    [pbVC addAMenuItem:@"增加照片" icon:[UIImage imageNamed:@"baby_icon_normal.png"] target:self action:@selector(deleteHomeworkFromPB:)];
    [pbVC addAMenuItem:@"删除照片" icon:[UIImage imageNamed:@"baby_icon_normal.png"] target:self action:@selector(deleteHomeworkFromPB:)];
    [pbVC show];
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
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat unitWidth = 150;
    CGFloat unitMargin = 5;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger numInARow = (int)((screenWidth - unitMargin) / (unitMargin + unitWidth));
    CGFloat realWith = (screenWidth - unitMargin) / numInARow - unitMargin;
    return CGSizeMake(realWith, realWith);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 2.5, 5, 2.5);
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

- (void)addPhotoToAlbum: (NSInteger)dirId {
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
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            self.pageIndex = 1;
            [self loadAlbumData:YES];
        } else {
            [KGUtil showCheckMark:@"删除失败" checked:NO inView:self.collectionView];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [KGUtil showCheckMark:@"请求删除失败" checked:NO inView:self.collectionView];
    } inView:self.collectionView showHud:NO showError:true];
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
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self.collectionView.header endRefreshing];
        [self.collectionView.footer endRefreshing];
    } inView:self.collectionView showHud:NO showError:true];
}

#pragma mark actions
- (IBAction)addButtonAction:(id)sender {
    NSLog(@"add new album");
    UIAlertView *hint = [[UIAlertView alloc] initWithTitle:@"新增相册" message:@"请输入您所要新建相册的目录名" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
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
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"click alert view");
    if (alertView.tag == 0) {  //新增相册目录
        if (buttonIndex == 0) { //确定
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
- (void)doPicPicked:(UIImage *)image
{
    //    NSLog(@"get image");
    if(image == nil)
        return;
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Growup" bundle:nil];
    GrowupEditViewController *vc = (GrowupEditViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"GrowDocEdit"];
    
    vc.image = image;
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
}

@end
