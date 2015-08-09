//
//  ChildTableViewController.m
//  kindergarten
//
//  Created by wangbin on 15/7/18.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "KGImageTableViewController.h"
#import "KGUtil.h"
#import "KGConst.h"
#import "AppDelegate.h"
#import "KGChild.h"
#import "KGImageTableViewCell.h"
//#import "KGImageDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "KGHomework.h"
#import "KGTeacherDesc.h"
#import "KGPicPicker.h"
#import "GrowupEditViewController.h"

@interface KGImageTableViewController ()<UIActionSheetDelegate, KGPicPickerDelegate, KGPostImageDelegate>

@property (nonatomic, strong) KGPicPicker *picPicker;      //拍照or从相册选择控件

@property (nonatomic, strong) NSMutableArray *imageInfos;  //为PhotoBrowser提供的图像信息数组

@end

@implementation KGImageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.homeworks = [[NSMutableArray alloc] init];
    
    self.pageIndex = 1;
    //[self loadTableData];
    
    if (self.type == HOMEWORK) {
        self.title = @"亲子成长";
    } else if (self.type == TEACHER) {
        self.title = @"教师风采";
    }

    // 设置下拉刷新
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.pageIndex = 1;
        [self loadTableData:YES];
    }];
    [self.tableView.header beginRefreshing];
    
    // 设置上拉刷新
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadTableData:NO];
    }];
    // 首次不显示
    self.tableView.footer.hidden = YES;

    if (![KGUtil isTeacherVersion]) {
        self.navigationItem.rightBarButtonItem = nil;
    }

    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
}

- (NSMutableArray *)imageTableRowInfos {
    if (_imageTableRowInfos == nil) {
        _imageTableRowInfos = [[NSMutableArray alloc] init];
    }
    return _imageTableRowInfos;
}

- (NSMutableArray *)imageInfos {
    if (_imageInfos == nil) {
        _imageInfos = [[NSMutableArray alloc] init];
    }
    return _imageInfos;
}

- (void)resetImageInfos {
    [self.imageInfos removeAllObjects];
    for (int i = 0; i < [self.imageTableRowInfos count]; i++) {
        KGImageTableRowInfo *rowInfo = (KGImageTableRowInfo *)[self.imageTableRowInfos objectAtIndex:i];
        PBImageInfo *iInfo = [[PBImageInfo alloc] init];
        iInfo.imageURL = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], rowInfo.picUrl];
        iInfo.imageTitle = rowInfo.createTime;
        iInfo.imageDesc = rowInfo.desc;
        iInfo.placeHolder = rowInfo.coverImage;
        [self.imageInfos addObject:iInfo];
    }
    self.pbVC.imageInfos = self.imageInfos;
}

- (PBViewController *)pbVC {
    if (_pbVC == nil) {
        _pbVC = [[PBViewController alloc] init];
        _pbVC.imageInfos = self.imageInfos;
        _pbVC.handleVC = self;
        if ([KGUtil isTeacherVersion]) {
            if (self.type == HOMEWORK) {
                [_pbVC addAMenuItem:@"增加亲子成长" icon:[UIImage imageNamed:@"icon_add.png"] target:self action:@selector(addImageTableRowInPB:)];
                [_pbVC addAMenuItem:@"删除亲子成长" icon:[UIImage imageNamed:@"icon_delete.png"] target:self action:@selector(deleteImageTableRowInPB:)];
            } else if (self.type == TEACHER) {
                [_pbVC addAMenuItem:@"增加教师风采" icon:[UIImage imageNamed:@"icon_add.png"] target:self action:@selector(addImageTableRowInPB:)];
                [_pbVC addAMenuItem:@"删除教师风采" icon:[UIImage imageNamed:@"icon_delete.png"] target:self action:@selector(deleteImageTableRowInPB:)];
            }
        }
    }
    return _pbVC;
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
            NSArray *objlistArray = (NSArray *)[responseObject objectForKey:@"objlist"];
            if (loadAll == YES) {
                [self.imageTableRowInfos removeAllObjects];
                self.imageTableRowInfos = [[NSMutableArray alloc] initWithCapacity:[objlistArray count]];;
            }
            for (int i = 0; i < [objlistArray count]; i++) {
                NSDictionary *hwDict = [objlistArray objectAtIndex:i];
                if (self.type == HOMEWORK) {
                    KGHomework *homework = [[KGHomework alloc] initWithDesc:[hwDict objectForKey:@"description"]
                                                                    classId:[[hwDict objectForKey:@"classId"] integerValue]
                                                                 homeworkId:[[hwDict objectForKey:@"homeworkId"] integerValue]
                                                                     picUrl:[hwDict objectForKey:@"picUrl"]
                                                                smallPicUrl:[hwDict objectForKey:@"smallPicUrl"]
                                                                   createAt:[hwDict objectForKey:@"createTime"]];
                    [self.imageTableRowInfos addObject:homework];
                } else if (self.type == TEACHER) {
                    KGTeacherDesc *teacherDesc = [[KGTeacherDesc alloc] initWithDesc:[hwDict objectForKey:@"description"]
                                                                       teacherDescId:[[hwDict objectForKey:@"teacherDescId"] integerValue]
                                                                              picUrl:[hwDict objectForKey:@"picUrl"]
                                                                         smallPicUrl:[hwDict objectForKey:@"smallPicUrl"]
                                                                            createAt:[hwDict objectForKey:@"createTime"]];
                    [self.imageTableRowInfos addObject:teacherDesc];
                }
            }
            [self.tableView reloadData];
            
            self.tableView.footer.hidden = NO;
            [self.tableView.header endRefreshing];
            [self.tableView.footer endRefreshing];
            if (self.imageTableRowInfos.count < pageTotalCount) {
                self.pageIndex += 1;
            } else {
                [self.tableView.footer noticeNoMoreData];
            }
            [self resetImageInfos];
            [self.pbVC resetToIndex:0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
    } inView:self.tableView showHud:NO showError:true];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
- (void)doPicPicked:(id)image {
    if (image == nil || ![image isKindOfClass:[UIImage class]]) {
        return;
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Growup" bundle:nil];
    GrowupEditViewController *vc = (GrowupEditViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"GrowDocEdit"];
    vc.image = image;
    vc.delegate = self;
    if (self.type == HOMEWORK) {
        vc.postType = ADD_HOMEWORK;
    } else if (self.type == TEACHER) {
        vc.postType = ADD_TEACHERDESC;
    } else {
        return;
    }
    [self presentViewController:vc animated:YES
                     completion:^(void){
                     }];
}

#pragma mark - KGPostImageDelegate
- (void)reloadData {
    self.pageIndex = 1;
    [self loadTableData:YES];
}


#pragma mark - tableview datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.imageTableRowInfos count];
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
        if(index < 0 || index >= [self.imageTableRowInfos count]) {
            return;
        }
        NSInteger infoId;
        if (self.type == HOMEWORK) {
            KGHomework *hw = [self.imageTableRowInfos objectAtIndex:index];
            if (hw) {
                infoId = hw.homeworkId;
            }
        } else if (self.type == TEACHER) {
            KGTeacherDesc *td = [self.imageTableRowInfos objectAtIndex:index];
            if (td) {
                infoId = td.teacherDescId;
            }
        } else {
            return;
        }
        [self deleteImageTableRow:infoId section:indexPath.section row:indexPath.row];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KGImageTableViewCell *cell = (KGImageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"imageTableRowCell" forIndexPath:indexPath];
    KGImageTableRowInfo *rowInfo = (KGImageTableRowInfo *)[self.imageTableRowInfos objectAtIndex:indexPath.row];
    if (rowInfo) {
        cell.descLabel.text = rowInfo.desc;
        cell.timeLabel.text = rowInfo.createTime;//[KGUtil getDateStr:homework.createTime];
        cell.smallPicUrl = rowInfo.smallPicUrl;
        cell.picUrl = rowInfo.picUrl;
        NSString *smallPicUrl = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], rowInfo.smallPicUrl];
        cell.picImageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.picImageView.clipsToBounds = YES;
        rowInfo.coverImage = [UIImage imageNamed:@"image_placeholder"];
        [cell.picImageView sd_setImageWithURL:[NSURL URLWithString:smallPicUrl]
                             placeholderImage:[UIImage imageNamed:@"image_placeholder"]
                                      options:SDWebImageProgressiveDownload
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                        rowInfo.coverImage = image;
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
    if (indexPath.row >= [self.imageTableRowInfos count] || indexPath.row < 0) {
        return;
    }
    /*NSMutableArray *imageInfos = [[NSMutableArray alloc] initWithCapacity:[self.imageTableRowInfos count]];
    for (int i = 0; i < [self.imageTableRowInfos count]; i++) {
        KGImageTableRowInfo *rowInfo = (KGImageTableRowInfo *)[self.imageTableRowInfos objectAtIndex:i];
        PBImageInfo *iInfo = [[PBImageInfo alloc] init];
        iInfo.imageURL = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], rowInfo.picUrl];
        iInfo.imageTitle = rowInfo.createTime;
        iInfo.imageDesc = rowInfo.desc;
        iInfo.placeHolder = rowInfo.coverImage;
        [imageInfos addObject:iInfo];
    }
    PBViewController *pbVC = [[PBViewController alloc] init];
    pbVC.index = indexPath.row;
    pbVC.handleVC = self;
    pbVC.imageInfos = imageInfos;
    if (self.type == HOMEWORK) {
        [pbVC addAMenuItem:@"删除亲子成长" icon:[UIImage imageNamed:@"baby_icon_normal.png"] target:self action:@selector(deleteImageTableRowInPB:)];
    } else if (self.type == TEACHER) {
        [pbVC addAMenuItem:@"删除教师风采" icon:[UIImage imageNamed:@"baby_icon_normal.png"] target:self action:@selector(deleteImageTableRowInPB:)];
    }
    [pbVC show];*/
    //[self createImageInfos];
//    if (self.imageInfos == nil || self.imageInfos.count == 0) {
//        return;
//    }
    self.pbVC.index = indexPath.row;
    self.pbVC.rowIndex = indexPath.row;
    self.pbVC.sectionIndex = indexPath.section;
    //self.pbVC.imageInfos = self.imageInfos;
    [self.pbVC show];
}

#pragma mark - add button action
- (IBAction)addButtonAction:(id)sender {
    [self addImageTableRow];
}

- (void)addImageTableRowInPB:(id)sender {
    [self addImageTableRow];
}

#pragma mark - delete row
- (void)deleteImageTableRow:(NSInteger)infoId section:(NSInteger)sec row:(NSInteger)row {
    if (![KGUtil isTeacherVersion]) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:sec];
    NSDictionary *data = nil;
    NSString *urlSuffix = @"";
    if (self.type == HOMEWORK) {
        data = @{@"homeworkId": @(infoId)};
        urlSuffix = @"/system/deleteHomework";
    } else if (self.type == TEACHER) {
        data = @{@"teacherDescId": @(infoId)};
        urlSuffix = @"/system/deleteTeacherDesc";
    } else {
        return;
    }
    NSDictionary *body = [KGUtil getRequestBody:data];
    NSDictionary *params = @{@"uid": REQUEST_UID, @"sign": [KGUtil getRequestSign:body], @"body":body};
    NSString *url = [[KGUtil getServerAppURL] stringByAppendingString:urlSuffix];
    UIView *view = [KGUtil getTopMostViewController].view;
    BOOL showHud = (view != nil);
    [KGUtil postRequest:url
             parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    NSString *code = [responseObject objectForKey:@"code"];
                    if ([code isEqualToString:@"000000"]) {
                        [self doDeleteImageTableRow:indexPath];
                        [self resetImageInfos];
                        [self.pbVC resetAsPageRemoved];
                    } else {
                        [KGUtil showCheckMark:@"删除失败" checked:NO inView:view];
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                    [KGUtil showCheckMark:@"请求删除失败" checked:NO inView:view];
                }
                 inView:view
                showHud:showHud
              showError:true];
}

- (void)doDeleteImageTableRow:(NSIndexPath *)indexPath {
    [self.imageTableRowInfos removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //[KGUtil showCheckMark:@"删除成功" checked:YES inView:self.tableView];
}


- (void)deleteImageTableRowInPB:(id)sender {
    if (![sender isKindOfClass:[KxMenuItem class]]) {
        return;
    }
    KxMenuItem *item = (KxMenuItem *)sender;
    NSInteger imageIndex = item.imageIndex;
    if (imageIndex < 0 || imageIndex >= self.imageTableRowInfos.count) {
        return;
    }
    NSInteger infoId;
    if (self.type == HOMEWORK) {
        KGHomework *hw = [self.imageTableRowInfos objectAtIndex:imageIndex];
        if (hw == nil) {
            return;
        }
        infoId = hw.homeworkId;
    } else if (self.type == TEACHER) {
        KGTeacherDesc *td = [self.imageTableRowInfos objectAtIndex:imageIndex];
        if (td == nil) {
            return;
        }
        infoId = td.teacherDescId;
    }
    [self deleteImageTableRow:infoId section:item.sectionIndex row:imageIndex];
}

#pragma mark add row
- (void)addImageTableRow {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

@end
