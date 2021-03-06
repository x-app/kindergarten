//
//  GrowupTableViewController.m
//  kindergarten
//
//  Created by ShiLiangdong on 15/7/19.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "GrowupTableViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
//#import "KGImageDetailViewController.h"
#import "PBImageInfo.h"
#import "PBViewController.h"
#import "MJRefresh.h"
#import "GrowDocCell.h"
#import "GrowDoc.h"
#import "KGUtil.h"
#import "KGChild.h"
#import "KGConst.h"
#import "KGPicPicker.h"
#import "GrowupEditViewController.h"

@interface GrowupTableViewController() <UIActionSheetDelegate, KGPicPickerDelegate, KGPostImageDelegate>

@property (nonatomic, strong) PBViewController *pbVC;

@property (nonatomic, strong)UITapGestureRecognizer *singleImgTap;
@property (nonatomic, strong) NSMutableArray *pbImgInfos;
@property (nonatomic) NSInteger curPageIndex;

@property (nonatomic) KGPicPicker *kgpp;
@end

@implementation GrowupTableViewController

- (KGPicPicker*)kgpp
{
    if(!_kgpp)
    {
        _kgpp = [[KGPicPicker alloc] initWithUIVC:self needCrop:FALSE];
        _kgpp.delegate = self;
    }
    
    return _kgpp;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.docs = [[NSMutableArray alloc] init];
    
    self.pbImgInfos = [[NSMutableArray alloc] init];
    
    self.tableView.separatorStyle = NO;
    
    self.curPageIndex = 1;
    
    self.singleImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAddClick:)];

    //[self loadNewData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    __weak GrowupTableViewController *wself = self;
    // 设置下拉刷新
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [wself loadNewData:true];
    }];
    [self.tableView.header beginRefreshing];
    
    // 设置上拉刷新
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [wself loadNewData:false];
    }];
    // 首次不显示
    self.tableView.footer.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated{
}

- (void)viewWillAppear:(BOOL)animated{
    // 去除cell选中状态
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PBViewController *)pbVC {
    if (_pbVC == nil) {
        _pbVC = [[PBViewController alloc] init];
        _pbVC.imageInfos = self.pbImgInfos;
        _pbVC.handleVC = self;
        [_pbVC addAMenuItem:@"删除" icon:[UIImage imageNamed:@"icon_delete.png"] target:self action:@selector(removeDoc:)];
    }
    return _pbVC;
}

- (void)loadNewData:(BOOL)isNew{
    KGChild *curchild = [KGUtil getCurChild];
    NSDictionary *profile = @{@"childId": [NSString stringWithFormat:@"%ld", (long)curchild.cid],
                              @"pageIndex": [NSString stringWithFormat:@"%ld", (long)self.curPageIndex],
                              @"pageSize": [NSString stringWithFormat:@"%d", KG_PAGE_SIZE]
                              };
    
    NSString *curl = @"/parent/pageQueryGrowthArchiveNew";
    [KGUtil postKGRequest:curl body:profile success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        //if(!self.isViewLoaded)
          //  return;
        
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            NSDictionary *obj = [responseObject objectForKey:@"obj"];
            NSInteger pageTotalCount = [[obj objectForKey:@"pageTotalCnt"] integerValue];
            
            NSArray *objlist = [responseObject objectForKey:@"objlist"];
            
            if(isNew){
                [self.docs removeAllObjects];
                [self.pbImgInfos removeAllObjects];
            }
            
            //NSInteger count = 0;
            for(int i=0; i<[objlist count]; i++)
            {
                NSDictionary *monthdata = objlist[i];
//                NSString *month = [monthdata objectForKey:@"month"];
                // growthArchives
                NSArray *docs = [monthdata objectForKey:@"growthArchives"];
                for(int j=0; j<docs.count; j++)
                {
                    NSDictionary *doc = docs[j];
            
                    GrowDoc *growdoc = [[GrowDoc alloc] initWithDate:[doc objectForKey:@"createTime"]
                                                             content:[doc objectForKey:@"description"]
                                                               docid:[doc objectForKey:@"growthArchiveId"]
                                                              picurl:[doc objectForKey:@"picUrl"]
                                                         smallpicurl:[doc objectForKey:@"smallPicUrl"]];
                    [self.docs addObject:growdoc];
                    
                    PBImageInfo *iInfo = [[PBImageInfo alloc] init];
                    NSString *picurl = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], growdoc.picurl];
                    iInfo.imageURL = picurl;
                    iInfo.imageTitle = growdoc.date;
                    iInfo.imageDesc = growdoc.content;
                    iInfo.placeHolder = [UIImage imageNamed:@"default_img"];
                    [self.pbImgInfos addObject:iInfo];

                    //count++;
                }
            }
            
            [self.tableView reloadData];
            
            self.tableView.footer.hidden = NO;
            [self.tableView.header endRefreshing];
            [self.tableView.footer endRefreshing];
            if(self.curPageIndex + KG_PAGE_SIZE-1 < pageTotalCount)
            {
                self.curPageIndex += KG_PAGE_SIZE;
            }
            else{
                [self.tableView.footer noticeNoMoreData];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
    } inView:self.view
     showHud:false];

}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.docs count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GrowDocCell *cell = (GrowDocCell *)[tableView dequeueReusableCellWithIdentifier:@"GrowDocCell"];
    
    if(indexPath.row == 0)
    {
        cell.dateLabel.text = @"今天";
        cell.docid = @"";
        cell.descLabel.text = @"";
    
        cell.imgView.image = [UIImage imageNamed:@"camera.png"];
        
        [cell.imgView addGestureRecognizer:self.singleImgTap];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        return cell;
    }
    else{
        [cell.imgView removeGestureRecognizer:self.singleImgTap];
    }
    
    NSInteger index = indexPath.row-1;
    GrowDoc *doc = (self.docs)[index];
    
    NSString *day = [doc.date substringWithRange:NSMakeRange(8,2)];
    NSString *month = [doc.date substringWithRange:NSMakeRange(5,2)];
    NSString *text = nil;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    if(index == 0)
    {//首个记录如果为当天，不显示日期
        NSString *dateStr = [df stringFromDate:[NSDate date]];
        if([[doc.date substringToIndex:10] isEqualToString:dateStr])
        {
//            text = @"今天";
            text = @"";
        }
    }
    
    NSString *yesdateStr = [df stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-(24*60*60)]];
    if([[doc.date substringToIndex:10] isEqualToString:yesdateStr])
    {
        text = @"昨天";
    }
    
    // 同一天的日期只显示一次，进行过滤
    if(index >= 1)
    {
        GrowDoc *lastDoc = (self.docs)[index-1];
        if([[lastDoc.date substringToIndex:10] isEqualToString:[doc.date substringToIndex:10]])
        {
            text = @"";
        }
    }
    
    if(text == nil)
    {
        text = [day stringByAppendingString:[KGUtil getMonthZn:[month integerValue]]];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
        [str addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(2,2)];
        cell.dateLabel.attributedText = str;
    }
    else{
        cell.dateLabel.text = text;
    }
    
    cell.docid = doc.docid;
    cell.descLabel.text = doc.content;
    
    cell.imgView.image = [UIImage imageNamed:@"image_placeholder"];
    cell.imgView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imgView.clipsToBounds = YES;
    
    if (doc.smallpicurl) {
        __block UIActivityIndicatorView *activityIndicator;
        __weak UIImageView *weakImageView = cell.imgView;
        NSString *picurl = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], doc.smallpicurl];
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:picurl]
                          placeholderImage:[UIImage imageNamed:@"image_placeholder"]
                                   options:SDWebImageProgressiveDownload
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                      if (!activityIndicator) {
                                          activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                                          [weakImageView addSubview:activityIndicator];
                                          activityIndicator.center = weakImageView.center;
                                          [activityIndicator startAnimating];
                                      }
                                  }
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     //NSLog(@"load image compelted");
                                     [activityIndicator removeFromSuperview];
                                     activityIndicator = nil;
                                     
                                     PBImageInfo *imageInfo = (PBImageInfo*)[self.pbImgInfos objectAtIndex:indexPath.row-1];
                                     imageInfo.placeHolder = image;
                                 }];
           }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 103;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < 1 || indexPath.row-1 >= [self.docs count]) {
        return;
    }

//    PBViewController *pbVC = [[PBViewController alloc] init];
    self.pbVC.index = indexPath.row-1;
    self.pbVC.rowIndex = indexPath.row-1;
    self.pbVC.sectionIndex = 0;
//    pbVC.handleVC = self;
//    pbVC.imageInfos = self.pbImgInfos;

    [self.pbVC show];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    GrowDocCell * cell = (GrowDocCell *)sender;
    
    
    GrowDoc *curDoc = nil;
    for (int i=0; i<[self.docs count]; i++) {
        GrowDoc *doc = self.docs[i];
        if(doc.docid == cell.docid)
        {
            curDoc = doc;
            break;
        }
    }
    
    if(curDoc != nil)
    {
        KGImageDetailViewController *detailViewController = segue.destinationViewController;;
        
        NSString *picurl = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], curDoc.picurl];
        detailViewController.imageURL = picurl;
        detailViewController.imageDesc = curDoc.content;
    }
}*/

#pragma mark
- (void)onAddClick:(UITapGestureRecognizer*) sender{
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        [self.kgpp takePhoto];
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        [self.kgpp selectPhoto];
    }
}

#pragma mark - KGPicPickerDelegate
- (void)doPicPicked:(NSArray *)images
{
    if (images == nil || images.count == 0) {
        return;
    }
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Growup" bundle:nil];
    GrowupEditViewController *vc = (GrowupEditViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"GrowDocEdit"];
    
    vc.images = [images mutableCopy];
    images = nil;
    vc.postType = ADD_GROWUP_DOC;
    vc.placeHolderText = @"记录宝宝的成长...";
    vc.delegate = self;
    [self presentViewController:vc animated:YES
                          completion:^(void){
                          }];
}

#pragma mark - delete cell
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0)
        return NO;
    
    return YES;
}

/*改变删除按钮的title*/
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger index = indexPath.row-1;
        if(index < 0 || index >= [self.docs count])
            return;
        
        [self removeDocAtIndex:index];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}

-(void)removeDocAtIndex:(NSInteger)index {
    
    if(index <0 || index >= self.docs.count)
        return;
    
    GrowDoc *doc = (self.docs)[index];
    NSDictionary *profile = @{@"growthArchiveId":doc.docid
                              };
    
    NSString *curl = @"/system/deleteGrowthArchive";
    [KGUtil postKGRequest:curl
                     body:profile
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      NSString *code = [responseObject objectForKey:@"code"];
                      if ([code isEqualToString:@"000000"]) {
                          [self doAfterRemoveDoc:index];
                      }
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      NSLog(@"Error: %@", error);
                  }
                   inView:self.view
                  showHud:true];
}

-(void)removeDoc:(id)sender {
    if (![sender isKindOfClass:[KxMenuItem class]]) {
        return;
    }
    KxMenuItem *item = (KxMenuItem *)sender;
    NSInteger index = item.imageIndex;
    [self removeDocAtIndex:index];
}

-(void)doAfterRemoveDoc:(NSInteger)index
{
    if(index < 0 || index >= self.docs.count)
        return;
    
    [self.docs removeObjectAtIndex:index];
    [self.pbImgInfos removeObjectAtIndex:index];
    self.pbVC.imageInfos = self.pbImgInfos;
    [self.pbVC resetAsPageRemoved];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index+1 inSection:0];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    // 指定更新被删除记录的下一记录。防止日期头被删除。
    if(index < self.docs.count)
    {
        [self.tableView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

#pragma mark - KGPostImageDelegate
- (void)reloadData {
    [self loadNewData:YES];
}

- (void)dealloc {
    NSLog(@"dealloc GrowupTableVC");
}
@end
