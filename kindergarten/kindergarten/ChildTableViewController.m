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
@interface ChildTableViewController ()

@end

@implementation ChildTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UIEdgeInsets edgeInset = self.tableView.separatorInset;
//    self.tableView.separatorInset = UIEdgeInsetsMake(edgeInset.top, 0, edgeInset.bottom, edgeInset.right);
    //[self.tableView setSeparatorInset:UIEdgeInsetsZero];
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    //self.homeworks = [[NSMutableArray alloc] init];
    /*for (int i = 0; i < 20; i++) {
        NSString *hwDesc = [NSString stringWithFormat:@"homework%d", i];
        KGHomework *hw = [[KGHomework alloc] initWithDesc: hwDesc classId:10001 homeworkId:i picUrl:@"test" smallPicUrl:@"test" createAt: [[NSDate alloc] init]];
        [self.homeworks addObject:hw];
    }*/
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.homeworks count];
}

#pragma mark - 代理方法
#pragma mark 设置每行高度（每行高度可以不一样）
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
/*
- (UIImage*)imageNamed:(NSString*)imageNamed cache:(BOOL)cache
{
    UIImage* retImage = [staticImageDictionary objectForKey:imageNamed];
    if (retImage == nil)
    {
        retImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageNamed]]];
        if (cache)
        {
            if (staticImageDictionary == nil)
                staticImageDictionary = [NSMutableDictionary new];
            [staticImageDictionary setObject:retImage forKey:imageNamed];
        }
    }
    return retImage;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ...
    // Add a view for the image (this is in section if cell = nil)
    NSString *tmp = [NSString stringWithFormat:@"%@", [[photoArray objectAtIndex:row] objectForKey:@"url"]];
    holder = [[[UIImageView alloc] initWithFrame:CGRectMake( 13, 2, 48, 50)] autorelease];
    holder.tag = 4;
    holder.contentMode = UIViewContentModeScaleToFill;
    // Here we either load from the web or we cache it...
    UIImage *ret = [self imageNamed:tmp cache:YES];
    holder.image = ret;
    ...
    [cell.contentView addSubview:holder];
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeworkCell" forIndexPath:indexPath];
    
    KGHomework *homework = (KGHomework *)[self.homeworks objectAtIndex:indexPath.row];
    if (homework) {
        cell.textLabel.text = homework.desc;
        cell.detailTextLabel.text = [KGUtil getDateStr:homework.createTime];
        cell.imageView.image = [UIImage imageNamed:@"image_placeholder"];
    }*/
    // Configure the cell...
    
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
        [cell.picImageView sd_setImageWithURL:[NSURL URLWithString:smallPicUrl]
                             placeholderImage:[UIImage imageNamed:@"image_placeholder"]
                                      options:SDWebImageRefreshCached];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        NSLog(@"aaaa");
//        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
//    }
//    
//    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        NSLog(@"bbbb");
//        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
//    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        NSLog(@"set separator");
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        NSLog(@"set layout margin");
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
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
