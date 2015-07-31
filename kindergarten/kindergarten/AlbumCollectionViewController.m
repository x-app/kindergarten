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
@interface AlbumCollectionViewController ()

@property (nonatomic) NSInteger pageIndex;

@end

@implementation AlbumCollectionViewController

static NSString * const reuseIdentifier = @"AlbumCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.pageIndex = 1;

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
    
    // Register cell classes
    //[self.collectionView registerClass:[AlbumCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)activityAlbums {
    if (_activityAlbums == nil) {
        _activityAlbums = [[NSMutableArray alloc] init];
    }
    return _activityAlbums;
}

- (void)loadAlbumData:(BOOL)loadAll {
    NSDictionary *data = @{@"classId": [[KGUtil getCurChild] classID],
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
    } inView:self.collectionView showHud:NO];
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
/*
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.activityAlbums.count;
}
//- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section < 0 || section >= self.activityAlbums.count) {
        return 0;
    }
    KGActivityAlbum *curAlbum = (KGActivityAlbum *)[self.activityAlbums objectAtIndex:section];
    return [curAlbum.albumInfos count];
}*/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
//- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.activityAlbums.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCollectionViewCell *cell = (AlbumCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumCell" forIndexPath:indexPath];
    //cell.backgroundColor = [UIColor blackColor];
    KGActivityAlbum *curAlbum = (KGActivityAlbum *)[self.activityAlbums objectAtIndex:indexPath.row];
    cell.albumNameLabel.text = curAlbum.dirName;
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
    // Configure the cell
    
    return cell;
}
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [self.activityAlbums count] || indexPath.row < 0) {
        return;
    }
    KGActivityAlbum *curAlbum = (KGActivityAlbum *)[self.activityAlbums objectAtIndex:indexPath.row];
    if (curAlbum == nil) {
        return;
    }
    NSMutableArray *imageInfos = [[NSMutableArray alloc] initWithCapacity:[curAlbum.albumInfos count]];
    for (int i = 0; i < [curAlbum.albumInfos count]; i++) {
        KGActivityAlbumInfo *aInfo = (KGActivityAlbumInfo *)[curAlbum.albumInfos objectAtIndex:i];
        PBImageInfo *iInfo = [[PBImageInfo alloc] init];
        iInfo.imageURL = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], aInfo.picUrl];
        iInfo.imageTitle = [NSString stringWithFormat:@"%ld/%ld", (long)(i + 1), (long)curAlbum.albumInfos.count];
        iInfo.imageDesc = aInfo.desc;
        [imageInfos addObject:iInfo];
    }
    PBViewController *pbVC = [[PBViewController alloc] init];
    pbVC.index = 0;
    pbVC.handleVC = self;
    pbVC.rowInHandleVC = indexPath.row;
    pbVC.imageInfos = imageInfos;
    [pbVC addAMenuItem:@"转存至成长档案" icon:[UIImage imageNamed:@"baby_icon_normal.png"] target:self action:@selector(saveToGrowupDoc:)];
    [pbVC show];
}

#pragma mark <UICollectionViewDelegate>

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

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat unitWidth = 150;
    CGFloat unitMargin = 5;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    NSLog(@"%f  %f", [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    NSUInteger numInARow = (int)((screenWidth - unitMargin) / (unitMargin + unitWidth));
    CGFloat realWith = (screenWidth - unitMargin) / numInARow - unitMargin;
    return CGSizeMake(realWith, realWith);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 2.5, 5, 2.5);
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
    NSLog(@"save to grow up doc");
    if (![sender isKindOfClass:[KxMenuItem class]]) {
        return;
    }
    KxMenuItem *item = (KxMenuItem *)sender;
    NSInteger indexInPB = item.indexInPB;
    NSInteger rowInSelf = item.rowInPBHandlerVC;
    KGActivityAlbumInfo *info = [self getAlbumInfo:rowInSelf infoIndex:indexInPB];
    if (info == nil) {
        return;
    }
    NSLog(@"row: %ld, index:%ld", rowInSelf, indexInPB);
    NSDictionary *data = @{@"childId": @([[[KGUtil getCurChild] cid] integerValue]),
                           @"activitiesAlbumInfoId": @(info.infoId)};
    NSDictionary *body = [KGUtil getRequestBody:data];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    NSString *urlSuffix = @"/parent/savePicToGrowthArchive";
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:urlSuffix];
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    } inView:self.collectionView showHud:YES];
}

@end
