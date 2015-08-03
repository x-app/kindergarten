//
//  ChildTableViewController.m
//  kindergarten
//
//  Created by wangbin on 15/7/18.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "ChildTableViewController.h"
#import "KGUtil.h"
#import "KGConst.h"
#import "AppDelegate.h"
#import "KGChild.h"
#import "HomeworkTableViewCell.h"
#import "KGImageDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "PBViewController.h"
#import "MJRefresh.h"
#import "KGHomework.h"
#import "KGPicPicker.h"
#import "GrowupEditViewController.h"

@interface ChildTableViewController ()<UIActionSheetDelegate, KGPicPickerDelegate, KGPostImageDelegate>

@property (nonatomic, strong) KGPicPicker *picPicker;
@property (nonatomic, strong) NSMutableArray *imageInfos;
@end

@implementation ChildTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.homeworks = [[NSMutableArray alloc] init];
    
    self.pageIndex = 1;
    //[self loadTableData];
    
    if (self.type == HOMEWORK) {
        self.title = @"亲子成长";
    } else if (self.type == TEACHER) {
        self.title = @"教师风采";
    }

    // 设置下拉刷新
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadTableData:YES];
    }];
    [self.tableView.header beginRefreshing];
    
    // 设置上拉刷新
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadTableData:NO];
    }];
    // 首次不显示
    self.tableView.footer.hidden = YES;
    if ([KGUtil isTeacherVersion]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewHomework)];
    }
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
}

- (KGPicPicker *)picPicker {
    if(_picPicker == nil) {
        _picPicker = [[KGPicPicker alloc] initWithUIVC:self needCrop:FALSE];
        _picPicker.delegate = self;
    }
    return _picPicker;
}

- (void)loadTableData: (BOOL)loadAll {
    NSDictionary *data = @{@"classID": @([KGUtil getCurClassId]),
                           @"pageIndex": @(self.pageIndex),
                           @"pageSize": @(10)};
    NSDictionary *body = [KGUtil getRequestBody:data];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    NSString *urlSuffix = @"";
    if (self.type == HOMEWORK) {
        urlSuffix = @"/system/pageQueryHomework";
    } else if (self.type == TEACHER) {
        urlSuffix = @"/system/pageQueryTeacherDesc";
    } else {
        NSLog(@"wrong type");
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        return;
    }
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:urlSuffix];
    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            NSDictionary *obj = [responseObject objectForKey:@"obj"];
            NSInteger pageTotalCount = [[obj objectForKey:@"pageTotalCnt"] integerValue];
            NSArray *homeworkArray = (NSArray *)[responseObject objectForKey:@"objlist"];
            if (loadAll == YES) {
                [self.homeworks removeAllObjects];
                self.homeworks = [[NSMutableArray alloc] initWithCapacity:[homeworkArray count]];;
            }
            for (int i = 0; i < [homeworkArray count]; i++) {
                NSDictionary *hwDict = [homeworkArray objectAtIndex:i];
                KGHomework *homework = [[KGHomework alloc] initWithDesc:[hwDict objectForKey:@"description"]
                                                                classId:[[hwDict objectForKey:@"classId"] integerValue]
                                                             homeworkId:[[hwDict objectForKey:@"homeworkId"] integerValue]
                                                                 picUrl:[hwDict objectForKey:@"picUrl"]
                                                            smallPicUrl:[hwDict objectForKey:@"smallPicUrl"]
                                                               createAt:[hwDict objectForKey:@"createTime"]];
                [self.homeworks addObject:homework];
            }
            [self.tableView reloadData];
            
            self.tableView.footer.hidden = NO;
            [self.tableView.header endRefreshing];
            [self.tableView.footer endRefreshing];
            if (self.homeworks.count < pageTotalCount) {
                self.pageIndex += 1;
            } else {
                [self.tableView.footer noticeNoMoreData];
            }
            //            self.pageIndex += 1;
            //            if (homeworkArray.count == 0) {
            //                [self.tableView.footer noticeNoMoreData];
            //            }
            //            if (self.pageIndex + homeworkArray.count < pageTotalCount) {
            //                self.pageIndex += homeworkArray.count;
            //            } else {
            //                [self.tableView.footer noticeNoMoreData];
            //            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
    } inView:self.tableView showHud:NO showError:true];
}

- (void)viewDidAppear:(BOOL)animated {
    //    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    NSDictionary *data = @{@"classID": [[KGUtil getCurChild] classID],
    //                           @"pageIndex": @1,
    //                           @"pageSize":@10};
    //    NSDictionary *body = [KGUtil getRequestBody:data];
    //    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    //    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:@"/system/pageQueryHomework"];
    //    [KGUtil postRequest:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //        NSLog(@"JSON: %@", responseObject);
    //        NSString *code = [responseObject objectForKey:@"code"];
    //        if ([code isEqualToString:@"000000"]) {
    //            NSArray *homeworkArray = (NSArray *)[responseObject objectForKey:@"objlist"];
    //            for (int i = 0; i < [homeworkArray count]; i++) {
    //                NSDictionary *hwDict = [homeworkArray objectAtIndex:i];
    //                KGHomework *homework = [[KGHomework alloc] initWithDesc:[hwDict objectForKey:@"description"]
    //                                                                classId:[[hwDict objectForKey:@"classId"] integerValue]
    //                                                             homeworkId:[[hwDict objectForKey:@"homeworkId"] integerValue]
    //                                                                 picUrl:[hwDict objectForKey:@"picUrl"]
    //                                                            smallPicUrl:[hwDict objectForKey:@"smallPicUrl"]
    //                                                               createAt:[hwDict objectForKey:@"createTime"]];
    //                [self.homeworks addObject:homework];
    //            }
    //        }
    //    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //        NSLog(@"Error: %@", error);
    //    } inView:self.tableView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
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
    vc.postType = ADD_HOMEWORK;
    [self presentViewController:vc animated:YES
                     completion:^(void){
                     }];
}

#pragma mark - KGPostImageDelegate
- (void)reloadData {
    [self loadTableData:YES];
}


#pragma mark - tableview datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.homeworks count];
}

#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [KGUtil isTeacherVersion];
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([KGUtil isTeacherVersion]) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger index = indexPath.row ;
        if(index < 0 || index >= [self.homeworks count]) {
            return;
        }
        KGHomework *hw = [self.homeworks objectAtIndex:index];
        [self deleteHomework:hw.homeworkId section:indexPath.section row:indexPath.row];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeworkTableViewCell *cell = (HomeworkTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"homeworkCell" forIndexPath:indexPath];
    KGHomework *homework = (KGHomework *)[self.homeworks objectAtIndex:indexPath.row];
    if (homework) {
        //cell.picImageView.image = [UIImage imageNamed:@"image_placeholder"];
        cell.descLabel.text = homework.desc;
        cell.timeLabel.text = homework.createTime;//[KGUtil getDateStr:homework.createTime];
        cell.smallPicUrl = homework.smallPicUrl;
        cell.picUrl = homework.picUrl;
        NSString *smallPicUrl = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], homework.smallPicUrl];
        cell.picImageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.picImageView.clipsToBounds = YES;
        homework.coverImage = [UIImage imageNamed:@"image_placeholder"];
        [cell.picImageView sd_setImageWithURL:[NSURL URLWithString:smallPicUrl]
                             placeholderImage:[UIImage imageNamed:@"image_placeholder"]
                                      options:SDWebImageProgressiveDownload
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                        homework.coverImage = image;
                                    }];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [self.homeworks count] || indexPath.row < 0) {
        return;
    }
    NSMutableArray *imageInfos = [[NSMutableArray alloc] initWithCapacity:[self.homeworks count]];
    for (int i = 0; i < [self.homeworks count]; i++) {
        KGHomework *hw = (KGHomework *)[self.homeworks objectAtIndex:i];
        PBImageInfo *iInfo = [[PBImageInfo alloc] init];
        iInfo.imageURL = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], hw.picUrl];
        iInfo.imageTitle = hw.createTime;
        iInfo.imageDesc = hw.desc;
        iInfo.placeHolder = hw.coverImage;
        [imageInfos addObject:iInfo];
    }
    PBViewController *pbVC = [[PBViewController alloc] init];
    pbVC.index = indexPath.row;
    pbVC.handleVC = self;
    pbVC.imageInfos = imageInfos;
    [pbVC addAMenuItem:@"删除亲子成长" icon:[UIImage imageNamed:@"baby_icon_normal.png"] target:self action:@selector(deleteHomeworkFromPB:)];
    [pbVC show];
}

#pragma mark - delete homework
- (void)deleteHomework:(NSInteger)homeworkId section:(NSInteger)sec row:(NSInteger)row {
    if (![KGUtil isTeacherVersion]) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:sec];
    NSDictionary *data = @{@"homeworkId": @(homeworkId)};
    NSDictionary *body = [KGUtil getRequestBody:data];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    NSString *urlSuffix = @"/system/deleteHomework";
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:urlSuffix];
    [KGUtil postRequest:url
             parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    NSString *code = [responseObject objectForKey:@"code"];
                    if ([code isEqualToString:@"000000"]) {
                        [self doDeleteHomework:indexPath];
                    } else {
                        [KGUtil showCheckMark:@"删除失败" checked:NO inView:self.tableView];
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                    [KGUtil showCheckMark:@"请求删除失败" checked:NO inView:self.tableView];
                }
                 inView:self.tableView
                showHud:NO
              showError:true];
}

- (void)doDeleteHomework:(NSIndexPath *)indexPath {
    [self.homeworks removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //[KGUtil showCheckMark:@"删除成功" checked:YES inView:self.tableView];
}


- (void)deleteHomeworkFromPB:(id)sender {
    if (![sender isKindOfClass:[KxMenuItem class]]) {
        return;
    }
    KxMenuItem *item = (KxMenuItem *)sender;
    NSInteger imageIndex = item.imageIndex;
    KGHomework *hw = [self.homeworks objectAtIndex:imageIndex];
    if (hw == nil) {
        return;
    }
    [self deleteHomework:hw.homeworkId section:item.sectionIndex row:item.rowIndex];
}

#pragma mark add homework
- (void)addNewHomework {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        if ([segue.destinationViewController isKindOfClass:[KGImageDetailViewController class]]
            && [sender isKindOfClass:[HomeworkTableViewCell class]]) {
            HomeworkTableViewCell *curCell = (HomeworkTableViewCell *)sender;
            KGImageDetailViewController *detailVC = (KGImageDetailViewController *)segue.destinationViewController;
            NSString *picUrl = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], curCell.picUrl];
            detailVC.imageURL = picUrl;
            detailVC.imageDesc = curCell.descLabel.text;
        }
    }
}


@end
