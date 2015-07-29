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
    
    [self.collectionView registerClass:[AlbumCollectionViewCell class] forCellWithReuseIdentifier:@"AlbumCell"];
    
    // 设置下拉刷新
    self.collectionView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadAlbumData];
    }];
    [self.collectionView.header beginRefreshing];
    
    // 设置上拉刷新
    self.collectionView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadAlbumData];
    }];
    // 首次不显示
    self.collectionView.footer.hidden = YES;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
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

- (void)loadAlbumData {
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
}

- (AlbumCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCollectionViewCell *cell = (AlbumCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blackColor];
    KGActivityAlbum *curAlbum = (KGActivityAlbum *)[self.activityAlbums objectAtIndex:indexPath.section];
    cell.albumNameLabel.text = @"aaaaa";//curAlbum.dirName;
    cell.albumImageView.image = [UIImage imageNamed:@"image_placeholder"];
    // Configure the cell
    
    return cell;
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
    return CGSizeMake(100, 100);
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

@end
