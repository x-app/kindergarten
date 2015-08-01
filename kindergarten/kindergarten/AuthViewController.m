//
//  AuthViewController.m
//  kindergarten
//
//  Created by 庄小仙 on 15/8/1.
//  Copyright (c) 2015年 xapp. All rights reserved.
//

#import "AuthViewController.h"
#import "KGUtil.h"
#import "QRCodeGenerator.h"
@interface AuthViewController ()

@end

@implementation AuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSString *)authorityString {
    
    /**
     SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
     LoginManager loginManager = new LoginManager(this);
     String res = "{\"type\":\"1\",\"time\":\"" + sdf.format(new Date())
     + "\",\"parent\":\"" + loginManager.getParentId()
     + "\",\"childlist\":[";
     ObjectMapper mapper = new ObjectMapper();
     List<Map<String, Object>> babyList = new ArrayList<Map<String, Object>>();
     try {
     babyList = mapper.readValue(loginManager.getBabyList(),
					ArrayList.class);
     } catch (JsonParseException e) {
     e.printStackTrace();
     } catch (JsonMappingException e) {
     e.printStackTrace();
     } catch (IOException e) {
     e.printStackTrace();
     }
     for (int i = 0; i < babyList.size(); i++) {
     res += "{\"child\":\""
					+ ((Map<String, Object>) babyList.get(i)).get("id")
     .toString() + "\"},";
     }
     Log.e("", res.substring(0, res.length() - 1) + "]}");
     return res.substring(0, res.length() - 1) + "]}";

     */
    NSString *dateStr = [KGUtil getDateStr:[[NSDate alloc] init]];
    NSString *childsStr = @"[";
    KGUser *curUser = [KGUtil getUser];
    for (int i = 0; i < curUser.childs.count; i++) {
        KGChild *curChild = [curUser.childs objectAtIndex:i];
        childsStr = [childsStr stringByAppendingFormat:@"{\"child\":\"%@\"}", curChild.cid];
        if (i != curUser.childs.count - 1) {
            childsStr = [childsStr stringByAppendingString:@","];
        }
    }
    childsStr = [childsStr stringByAppendingString:@"]"];
    NSInteger parentId = curUser.parentID;
    NSString *contentStr = [NSString stringWithFormat:@"{\"type\":\"1\",\"time\":\"%@\",\"parent\":\"%ld\",\"childlist\":%@}", dateStr, (long)parentId, childsStr];
    NSLog(@"content string: %@", contentStr);
    NSString *finalContentStr = [NSString stringWithFormat:@"AA%@ZZ", [KGUtil base64StringFromText:contentStr]];
    NSLog(@"final content string:%@", finalContentStr);
    return finalContentStr;
}

- (void)generateQRCode {
    self.qrCodeImageView.image = [QRCodeGenerator qrImageForString:[self authorityString] imageSize:self.qrCodeImageView.bounds.size.width];
}

- (void)viewWillAppear:(BOOL)animated {
    NSDate *today = [[NSDate alloc] init];
    self.validDateLabel.text = [NSString stringWithFormat:@"有效日期: %@", [KGUtil getChnDateStr:today]];
    [self generateQRCode];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
