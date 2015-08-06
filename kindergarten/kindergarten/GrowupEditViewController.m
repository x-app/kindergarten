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

@interface GrowupEditViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@end

@implementation GrowupEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(self.image != nil)
        [self.imgView setImage:self.image];
    
    if(self.textView != nil)
        self.textView.delegate = self;
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
@end
