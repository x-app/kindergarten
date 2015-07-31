//
//  KxMenu.m
//  kxmenu project
//  https://github.com/kolyvan/kxmenu/
//
//  Created by Kolyvan on 17.05.13.
//

#import "KxMenu.h"
#import <QuartzCore/QuartzCore.h>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@interface KxMenuView : UIView
@end

@interface KxMenuOverlay : UIView
@end

@implementation KxMenuOverlay

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        UITapGestureRecognizer *gestureRecognizer;
        gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(singleTap:)];
        [self addGestureRecognizer:gestureRecognizer];
    }
    return self;
}

// thank horaceho https://github.com/horaceho
// for his solution described in https://github.com/kolyvan/kxmenu/issues/9

- (void)singleTap:(UITapGestureRecognizer *)recognizer {
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[KxMenuView class]]) {
            //KxMenuView *menuView = (KxMenuView *)v;
            //if ([menuView respondsToSelector:@selector(dismissMenu:)]) {
                [KxMenu dismissMenu];
                //[menuView performSelector:@selector(dismissMenu:) withObject:@(YES)];
            //}
        }
    }
}

@end

@implementation KxMenuItem

+ (instancetype) menuItem:(NSString *) title
                    image:(UIImage *) image
                   target:(id)target
                   action:(SEL) action {
    return [[KxMenuItem alloc] init:title
                              image:image
                             target:target
                             action:action];
}

- (id)init:(NSString *)title
      image:(UIImage *)image
     target:(id)target
     action:(SEL) action {
    NSParameterAssert(title.length || image);
    
    self = [super init];
    if (self) {
        _title = title;
        _image = image;
        _target = target;
        _action = action;
    }
    return self;
}

- (BOOL)enabled {
    return _target != nil && _action != NULL;
}

- (void)performAction {
    __strong id target = self.target;
    if (target && [target respondsToSelector:_action]) {
        [target performSelectorOnMainThread:_action withObject:self waitUntilDone:YES];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ #%p %@>", [self class], self, _title];
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation KxMenuView {
    UIView   *_contentView;
    NSArray  *_menuItems;
}

- (id)init {
    self = [super initWithFrame:CGRectZero];    
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.alpha = 0;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeMake(2, 2);
        self.layer.shadowRadius = 2;
    }
    return self;
}

- (void)setupFrameInView:(UIView *)view
                 fromRect:(CGRect)fromRect {
    const CGSize contentSize = _contentView.frame.size;
    const CGFloat outerWidth = view.bounds.size.width;
    const CGFloat frameY = fromRect.origin.y + fromRect.size.height;
    self.frame = CGRectMake(outerWidth - contentSize.width, frameY, contentSize.width, contentSize.height);
}

- (void)showMenuInView:(UIView *)view
              fromRect:(CGRect)rect
             menuItems:(NSArray *)menuItems {
    _menuItems = menuItems;
    
    _contentView = [self mkContentView];
    [self addSubview:_contentView];
    [self setupFrameInView:view fromRect:rect];
        
    KxMenuOverlay *overlay = [[KxMenuOverlay alloc] initWithFrame:view.bounds];
    [overlay addSubview:self];
    [view addSubview:overlay];
    
    //_contentView.hidden = YES;
    const CGRect toFrame = self.frame;
    const CGRect toContentFrame = _contentView.frame;
    //self.frame = (CGRect){self.arrowPoint, self.frame.size.width, 0};
    self.frame = (CGRect){self.frame.origin, self.frame.size.width, 1};
    _contentView.frame = (CGRect){_contentView.frame.origin.x, _contentView.frame.origin.y - _contentView.frame.size.height, _contentView.frame.size.width, _contentView.frame.size.height};
    //self.alpha = 0.1;
    [UIView animateWithDuration:0.3
                     animations:^(void) {
                         self.alpha = 1.0f;
                         self.frame = toFrame;
                         _contentView.frame = toContentFrame;
                     } completion:^(BOOL completed) {
                         //_contentView.hidden = NO;
                     }];
   
}

- (void)dismissMenu:(BOOL)animated {
    if (self.superview) {
        if (animated) {
            _contentView.hidden = YES;            
            const CGRect toFrame = (CGRect){self.frame.origin, self.frame.size.width, 0};
            [UIView animateWithDuration:0.3
                             animations:^(void) {
                                 //self.alpha = 0;
                                 self.frame = toFrame;
                             } completion:^(BOOL finished) {
                                 if ([self.superview isKindOfClass:[KxMenuOverlay class]]) {
                                     [self.superview removeFromSuperview];
                                 }
                                 [self removeFromSuperview];
                             }];
        } else {
            if ([self.superview isKindOfClass:[KxMenuOverlay class]]) {
                [self.superview removeFromSuperview];
            }
            [self removeFromSuperview];
        }
    }
}

- (void)performAction:(id)sender
{
    [self dismissMenu:YES];
    
    UIButton *button = (UIButton *)sender;
    KxMenuItem *menuItem = _menuItems[button.tag];
    [menuItem performAction];
}

- (UIView *)mkContentView
{
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    
    if (!_menuItems.count) {
        return nil;
    }
 
    const CGFloat kMinMenuItemHeight = 36.f;
    const CGFloat kMinMenuItemWidth = 100.f;
    const CGFloat kMarginX = 5.f;
    const CGFloat kMarginY = 2.f;
    const CGFloat imageSize = 18.f;
    
    //UIFont *titleFont = [KxMenu titleFont];
    //if (!titleFont) titleFont = [UIFont boldSystemFontOfSize:16];
    UIFont *titleFont = [UIFont boldSystemFontOfSize:14];
    
    //CGFloat maxImageWidth = 0;
    //CGFloat maxItemHeight = 0;
    CGFloat maxItemWidth = 0;
    
    /*for (KxMenuItem *menuItem in _menuItems) {
        
        const CGSize imageSize = menuItem.image.size;        
        if (imageSize.width > maxImageWidth)
            maxImageWidth = imageSize.width;        
    }
    
    if (maxImageWidth) {
        maxImageWidth += kMarginX;
    }*/
    //maxImageWidth = 24;
    for (KxMenuItem *menuItem in _menuItems) {
        //const CGSize titleSize = [menuItem.title sizeWithFont:titleFont];
        const CGSize titleSize = [menuItem.title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        CGFloat itemWidth = imageSize + titleSize.width + kMarginX * 4;
        if (itemWidth > maxItemWidth) {
            maxItemWidth = itemWidth;
        }
    }
       
    maxItemWidth  = MAX(maxItemWidth, kMinMenuItemWidth);
    CGFloat maxItemHeight = 40;
    //maxItemHeight = MAX(maxItemHeight, kMinMenuItemHeight);
    //maxItemWidth = 100;
    //maxItemHeight = 32;

    const CGFloat titleX = kMarginX * 3 + imageSize;//maxImageWidth;
    const CGFloat titleWidth = maxItemWidth - imageSize - kMarginX * 4;
    
    UIImage *selectedImage = [KxMenuView selectedImage:(CGSize){maxItemWidth, maxItemHeight}];
    UIImage *gradientLine = [KxMenuView gradientLine:(CGSize){maxItemWidth - kMarginX * 2, 1}];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.autoresizingMask = UIViewAutoresizingNone;
    contentView.backgroundColor = [UIColor clearColor];
    contentView.opaque = NO;
    
    CGFloat itemY = 0;
    NSUInteger itemNum = 0;
        
    for (KxMenuItem *menuItem in _menuItems) {
        const CGRect itemFrame = (CGRect){0, itemY, maxItemWidth, maxItemHeight};
        
        UIView *itemView = [[UIView alloc] initWithFrame:itemFrame];
        itemView.autoresizingMask = UIViewAutoresizingNone;
        itemView.backgroundColor = [UIColor clearColor];        
        itemView.opaque = NO;
                
        [contentView addSubview:itemView];
        
        if (menuItem.enabled) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = itemNum;
            button.frame = itemView.bounds;
            button.enabled = menuItem.enabled;
            button.backgroundColor = [UIColor clearColor];
            button.opaque = NO;
            button.autoresizingMask = UIViewAutoresizingNone;
            
            [button addTarget:self
                       action:@selector(performAction:)
             forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
            [itemView addSubview:button];
        }
        
        if (menuItem.title.length) {
            CGRect titleFrame = (CGRect){titleX, kMarginY, titleWidth, maxItemHeight - kMarginY * 2};
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
            titleLabel.text = menuItem.title;
            titleLabel.backgroundColor = [UIColor yellowColor];
            titleLabel.font = titleFont;
            titleLabel.textAlignment = menuItem.alignment;
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.autoresizingMask = UIViewAutoresizingNone;
            //titleLabel.backgroundColor = [UIColor greenColor];
            [itemView addSubview:titleLabel];            
        }
        
        if (menuItem.image) {
            //const CGRect imageFrame = {kMarginX * 2, kMarginY, maxImageWidth, maxItemHeight - kMarginY * 2};
            const CGRect imageFrame = {kMarginX, kMarginY + (maxItemHeight - 2 * kMarginY - imageSize) / 2.0, imageSize, imageSize};
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
            imageView.image = menuItem.image;
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.autoresizingMask = UIViewAutoresizingNone;
            [itemView addSubview:imageView];
        }
        
        if (itemNum < _menuItems.count - 1) {
            UIImageView *gradientView = [[UIImageView alloc] initWithImage:gradientLine];
            gradientView.frame = (CGRect){kMarginX, maxItemHeight + 1, gradientLine.size};
            gradientView.contentMode = UIViewContentModeLeft;
            [itemView addSubview:gradientView];
            //itemY += 2;
        }
        
        itemY += maxItemHeight;
        ++itemNum;
    }    
    
    contentView.frame = (CGRect){0, 0, maxItemWidth, itemY + kMarginY};
    
    return contentView;
}

- (CGPoint)arrowPoint {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGPoint p = (CGPoint){screenBounds.size.width, 0};
    return p;
}

+ (UIImage *)selectedImage: (CGSize)size
{
    const CGFloat locations[] = {0,1};
    const CGFloat components[] = {
        0.216, 0.471, 0.871, 1,
        0.059, 0.353, 0.839, 1,
    };
    return [self gradientImageWithSize:size locations:locations components:components count:2];
}

+ (UIImage *)gradientLine: (CGSize) size
{
    const CGFloat locations[5] = {0,0.2,0.5,0.8,1};
    const CGFloat R = 0.44f, G = 0.44f, B = 0.44f;
    const CGFloat components[20] = {
        R,G,B,0.1,
        R,G,B,0.4,
        R,G,B,0.7,
        R,G,B,0.4,
        R,G,B,0.1
    };
    return [self gradientImageWithSize:size locations:locations components:components count:5];
}

+ (UIImage *)gradientImageWithSize:(CGSize) size
                          locations:(const CGFloat []) locations
                         components:(const CGFloat []) components
                              count:(NSUInteger)count
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef colorGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawLinearGradient(context, colorGradient, (CGPoint){0, 0}, (CGPoint){size.width, 0}, 0);
    CGGradientRelease(colorGradient);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)drawRect:(CGRect)rect
{
    [self drawBackground:self.bounds
               inContext:UIGraphicsGetCurrentContext()];
}

- (void)drawBackground:(CGRect)frame
             inContext:(CGContextRef)context
{
    [[UIColor colorWithRed:40.f/255 green:40.f/255 blue:40.f/255 alpha:1.0] set];

    UIBezierPath *outerPath = [UIBezierPath bezierPathWithRect:frame];
    [outerPath fill];
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static KxMenu *gMenu;
static UIColor *gTintColor;

@implementation KxMenu {
    KxMenuView *_menuView;
}

+ (instancetype)sharedMenu {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gMenu = [[KxMenu alloc] init];
    });
    return gMenu;
}

- (id)init {
    NSAssert(!gMenu, @"singleton object");
    self = [super init];
    if (self) {
    }
    return self;
}


- (void)showMenuInView:(UIView *)view
              fromRect:(CGRect)rect
             menuItems:(NSArray *)menuItems {
    NSParameterAssert(view);
    NSParameterAssert(menuItems.count);
    
    if (_menuView) {
        [_menuView dismissMenu:YES];
        _menuView = nil;
        return;
    }
    _menuView = [[KxMenuView alloc] init];
    [_menuView showMenuInView:view fromRect:rect menuItems:menuItems];    
}

- (void)dismissMenu {
    if (_menuView) {
        [_menuView dismissMenu:YES];
        _menuView = nil;
    }
}

+ (void)showMenuInView:(UIView *)view
               fromRect:(CGRect)rect
              menuItems:(NSArray *)menuItems {
    [[self sharedMenu] showMenuInView:view fromRect:rect menuItems:menuItems];
}

+ (void)dismissMenu {
    [[self sharedMenu] dismissMenu];
}

@end
