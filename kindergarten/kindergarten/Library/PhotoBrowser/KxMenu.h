//
//  KxMenu.h
//  kxmenu project
//  https://github.com/kolyvan/kxmenu/
//
//  Created by Kolyvan on 17.05.13.
//  modified 2015-07-31 根据项目大大简化绘制:
//    (1)固定从右上角弹出
//    (2)固定高度，不根据图标高度变化，图标尺寸缩小固定并充满
//    (3)内部尺寸调整，美化


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface KxMenuItem : NSObject

@property (readwrite, nonatomic, strong) UIImage *image;
@property (readwrite, nonatomic, strong) NSString *title;
@property (readwrite, nonatomic, weak) id target;
@property (readwrite, nonatomic) SEL action;

//当前弹出菜单时，PhotoBrowser上的索引
@property (nonatomic) NSInteger indexInPB;
@property (nonatomic) NSInteger rowInPBHandlerVC;

//@property (readwrite, nonatomic, strong) UIColor *foreColor;
@property (readwrite, nonatomic) NSTextAlignment alignment;

+ (instancetype) menuItem:(NSString *) title
                    image:(UIImage *) image
                   target:(id)target
                   action:(SEL) action;

@end

@interface KxMenu : NSObject

+ (void) showMenuInView:(UIView *)view
               fromRect:(CGRect)rect
              menuItems:(NSArray *)menuItems;

+ (void) dismissMenu;

@end
