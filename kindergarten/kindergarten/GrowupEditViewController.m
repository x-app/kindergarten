//
//  GrowupEditViewController.m
//  kindergarten
//
//  Created by ShiLiangdong on 15/7/29.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "GrowupEditViewController.h"
#import "KGUtil.h"
#import "AlbumCollectionViewController.h"
#import "KGImageTableViewController.h"
#import "ImageEditCollectionViewCell.h"
@interface GrowupEditViewController ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;
@end

@implementation GrowupEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(self.image != nil)
        [self.imgView setImage:self.image];
    
    if(self.textView != nil)
        self.textView.delegate = self;
    
    self.imagesCollectionView.delegate = self;
    self.imagesCollectionView.dataSource = self;
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

- (IBAction)onSend:(id)sender {
    [self.textView resignFirstResponder];
    NSString *attrName = @"";
    NSData* attrValue = nil;
    NSString *url = @"";
    if ([KGUtil isTeacherVersion]) {
        if (self.postType == ADD_HOMEWORK) {
            url = @"/system/insertHomework";
            attrName = @"classId";
            attrValue = [[NSString stringWithFormat:@"%ld", (long)[KGUtil getCurClassId]] dataUsingEncoding:NSUTF8StringEncoding];
        } else if (self.postType == ADD_TEACHERDESC) {
            url = @"/system/insertTeacherDesc";
            attrValue = nil;
            attrName = nil;
        } else if (self.postType == ADD_ALBUM_PHOTO) {
            url = @"/teacher/insertActivitiesAlbumInfo";
            attrName = @"directoryId";
            attrValue = [[NSString stringWithFormat:@"%ld", (long)self.albumDirId] dataUsingEncoding:NSUTF8StringEncoding];
        } else if (self.postType == ADD_CLASS_DESC) {
            url = @"/system/insertClassDesc";
            attrName = @"classId";
            attrValue = [[NSString stringWithFormat:@"%ld", (long)[KGUtil getCurClassId]] dataUsingEncoding:NSUTF8StringEncoding];
        } else if (self.postType == ADD_GARTEN_DESC) {
            url = @"/system/insertKindergartenDesc";
            attrName = nil;
            attrValue = nil;
        } else {
            return;
        }
    } else {
        if (self.postType == ADD_GROWUP_DOC) {
            url = @"/system/insertGrowthArchive";
            attrName = @"childId";
            KGChild *curchild = [KGUtil getCurChild];
            NSString *childid = [NSString stringWithFormat:@"%ld", (long)curchild.cid];
            attrValue = [childid dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            return;
        }
    }
     [KGUtil uploadImage:url
                   image:self.image
             description:self.textView.text
              customAttr:attrName
             customValue:attrValue
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSString *code = [responseObject objectForKey:@"code"];
                     if ([code isEqualToString:@"000000"]) {
                         NSLog(@"succ");
                         //reload
                         //     [self loadNewData:true];
                        [self dismissViewControllerAnimated:YES completion:nil];
                        if(self.delegate)// && [self.delegate respondsToSelector:@selector(reloadData)])
                             [self.delegate reloadData];
                     }
                     else
                     {
                        NSString *msg = [responseObject objectForKey:@"msg"];
                        if([msg length] > 0)
                            NSLog(@"Error: %@", msg);
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Error: %@", error);
                 }
                  inView:self.view
                 showHud:true];
}

- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - textview delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.text = @"";
    textView.textColor = [UIColor blackColor];

    return YES;
}

#pragma mark - UICollectionViewDatasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.postType == ADD_ALBUM_PHOTO) {
        //活动相册支持多图, 仿照微信, 最后一个cell是类似于微信的增加按钮
        return self.images.count + 1;
    } else {
        return self.images.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageEditCollectionViewCell *cell = (ImageEditCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageEditCell" forIndexPath:indexPath];
    cell.deleteItemView.hidden = YES;
    if (indexPath.row == self.images.count) {
        cell.imageItemView.image = [UIImage imageNamed:@"camera.png"];
        cell.isAddButton = YES;
    } else {
        cell.isAddButton = NO;
        cell.imageItemView.image = [self.images objectAtIndex:indexPath.row];
    }
    if (self.postType == ADD_ALBUM_PHOTO) {
        UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCellAction:)];
        [cell addGestureRecognizer:longPressGR];
        longPressGR.minimumPressDuration = 0.7;
        longPressGR.delegate = self;
        longPressGR.view.tag = indexPath.row;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    NSInteger colsNum = 4; //每行四个
    CGFloat unitMargin = 5;
    CGFloat unitWidth = (int)((screenWidth - (colsNum + 1) * unitMargin) / colsNum) ;
    return CGSizeMake(unitWidth, unitWidth);
}

#pragma mark - Actions
- (void)addButtonAction:(id)sender {

}

- (void)longPressCellAction:(id)sender {
    NSArray *visibleCells = self.imagesCollectionView.visibleCells;
    for (int i = 0; i < visibleCells.count; i++) {
        ImageEditCollectionViewCell *curCell = (ImageEditCollectionViewCell *)[visibleCells objectAtIndex:i];
        if (curCell == nil) {
            continue;
        }
        if (!curCell.isAddButton) {
            curCell.deleteItemView.hidden = NO;
        }
    }
    [self.imagesCollectionView reloadData];
}

@end
