//
//  GrowupTableViewController.m
//  kindergarten
//
//  Created by ShiLiangdong on 15/7/19.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "GrowupTableViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "KGImageDetailViewController.h"
#import "GrowDocCell.h"
#import "GrowDoc.h"
#import "KGUtil.h"
#import "KGChild.h"
#import "KGConst.h"

@interface GrowupTableViewController ()

@end

@implementation GrowupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.docs = [[NSMutableArray alloc] init];
    
    self.tableView.separatorStyle = NO;

    [self reloadTable];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewDidAppear:(BOOL)animated{
//    [self reloadTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTable{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    KGChild *curchild = [KGUtil getCurChild];
    NSDictionary *profile = @{@"childId": curchild.cid,
                              @"pageIndex": @"0",
                              @"pageSize": [NSString stringWithFormat:@"%d", KG_PAGE_SIZE]
                              };
    
    NSString *curl = @"/parent/pageQueryGrowthArchiveNew";
    [KGUtil postKGRequest:curl body:profile success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"000000"]) {
            NSDictionary *obj = [responseObject objectForKey:@"obj"];
            NSInteger pageCount = [[obj objectForKey:@"pageTotalCnt"] integerValue];
            
            NSArray *objlist = [responseObject objectForKey:@"objlist"];
            
            [self.docs removeAllObjects];
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
//                    growdoc.content = @"测试测试试test test test测试中文测试中文测试中文测试中文";
                    
                    [self.docs addObject:growdoc];
                }
            }
            
            [self.tableView reloadData];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    } inView:self.view];

}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.docs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GrowDocCell *cell = (GrowDocCell *)[tableView dequeueReusableCellWithIdentifier:@"GrowDocCell"];
    
    NSInteger index = indexPath.row;
    GrowDoc *doc = (self.docs)[index];
    
    NSString *day = [doc.date substringWithRange:NSMakeRange(8,2)];
    NSString *month = [doc.date substringWithRange:NSMakeRange(5,2)];
    NSString *text = nil;
    
    if(index == 0)
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr = [df stringFromDate:[NSDate date]];

        if([[doc.date substringToIndex:10] isEqualToString:dateStr])
        {
            text = @"今天";
        }
    }
    
    if(index-1 >= 0)
    {
        GrowDoc *lastDoc = (self.docs)[index-1];
        if([[lastDoc.date substringToIndex:10] isEqualToString:[doc.date substringToIndex:10]])
        {
            text = @"";
        }
    }
    
    cell.docid = doc.docid;
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
//    if([month isEqualToString:@"天"])
//    {
//        [cell.monLabel setFont:[UIFont boldSystemFontOfSize:28]];
//        [cell.monLabel sizeToFit];
//        cell.monLabel.text = month;
//    }
//    else
//    {
//        cell.monLabel.text = [KGUtil getMonthZn:[month integerValue]];
//    }
    cell.descLabel.text = doc.content;
    cell.imgView.image = [UIImage imageNamed:@"image_placeholder"];
//    cell.imgView.image = [self imageForRating:doc.pic];
    
//    [cell.descLabel sizeToFit];
    
    if (doc.smallpicurl) {
        __block UIActivityIndicatorView *activityIndicator;
        __weak UIImageView *weakImageView = cell.imgView;
        NSString *picurl = [NSString stringWithFormat:@"%@%@", [KGUtil getServerAppURL], doc.smallpicurl];
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:picurl]
                          placeholderImage:nil
                                   options:SDWebImageProgressiveDownload
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                      if (!activityIndicator) {
                                          activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                                          [weakImageView addSubview:activityIndicator];
                                          activityIndicator.center = weakImageView.center;
                                          [activityIndicator startAnimating];
                                      }
                                  }
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     NSLog(@"load image compelted");
                                     [activityIndicator removeFromSuperview];
                                     activityIndicator = nil;
                                 }];
           }

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 103;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{}

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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
