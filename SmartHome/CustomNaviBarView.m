//
//  CustomNaviBarView.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/11.
//  Copyright © 2017年 ECloud. All rights reserved.
//

#import "CustomNaviBarView.h"

#define FLOAT_TitleSizeNormal               19.0f
#define FLOAT_TitleSizeMini                 14.0f
#define RGB_TitleNormal                     RGB(255.0f, 255.0f, 255.0f, 1)
#define RGB_TitleMini                       [UIColor blackColor]

@interface CustomNaviBarView ()

@property (nonatomic, readonly) UIButton *m_btnBack;
@property (nonatomic, readonly) UILabel *m_labelTitle;
@property (nonatomic, readonly) UIButton *m_netStateView;
@property (nonatomic, readonly) UIImageView *m_imgViewBg;
@property (nonatomic, readonly) UIButton *m_btnLeft;
@property (nonatomic, readonly) UIButton *m_btnRight;
@property (nonatomic, readonly) BOOL m_bIsBlur;


@end

@implementation CustomNaviBarView

@synthesize m_btnBack = _btnBack;
@synthesize m_labelTitle = _labelTitle;
@synthesize m_imgViewBg = _imgViewBg;
@synthesize m_btnLeft = _btnLeft;
@synthesize m_btnRight = _btnRight;
@synthesize m_bIsBlur = _bIsBlur;
@synthesize m_netStateView = _netStateView;


+ (CGRect)rightBtnFrame
{
   return Rect(UI_SCREEN_WIDTH-[[self class] barBtnSize].width, 22.0f, [[self class] barBtnSize].width, [[self class] barBtnSize].height);
}

+ (CGSize)barBtnSize
{
   return Size(60.0f, 40.0f);
}

+ (CGSize)barSize
{
   return Size(UI_SCREEN_WIDTH, 64.0f);
}

+ (CGRect)titleViewFrame
{
    return Rect((UI_SCREEN_WIDTH-190.0f)/2, 22.0f, 190.0f, 40.0f);
}

+ (CGRect)titleViewFrameForNet
{
    return Rect((UI_SCREEN_WIDTH-190.0f)/2, 15.0f, 190.0f, 40.0f);
}

// 创建一个导航条按钮：使用默认的按钮图片。
+ (UIButton *)createNormalNaviBarBtnByTitle:(NSString *)strTitle target:(id)target action:(SEL)action
{
    UIButton *btn = [[self class] createImgNaviBarBtnByImgNormal:@"NaviBtn_Normal" imgHighlight:@"NaviBtn_Normal_H" target:target action:action];
    [btn setTitle:strTitle forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [Utilities label:btn.titleLabel setMiniFontSize:8.0f forNumberOfLines:1];
    
    return btn;
}

// 创建一个带标题和图片的按钮
+ (UIButton *)createNormalNaviBarBtnByTitle:(NSString *)strTitle imgNormal:(NSString *)strImg imgHighlight:(NSString *)strImgHighlight target:(id)target action:(SEL)action
{
    UIButton *btn = [[self class] createImgNaviBarBtnByImgNormal:strImg imgHighlight:strImgHighlight target:target action:action];
    [btn setTitle:strTitle forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [Utilities label:btn.titleLabel setMiniFontSize:8.0f forNumberOfLines:1];
    
    return btn;
}


// 创建一个导航条按钮：自定义按钮图片。
+ (UIButton *)createImgNaviBarBtnByImgNormal:(NSString *)strImg imgHighlight:(NSString *)strImgHighlight target:(id)target action:(SEL)action
{
    return [[self class] createImgNaviBarBtnByImgNormal:strImg imgHighlight:strImgHighlight imgSelected:strImg target:target action:action];
}
+ (UIButton *)createImgNaviBarBtnByImgNormal:(NSString *)strImg imgHighlight:(NSString *)strImgHighlight imgSelected:(NSString *)strImgSelected target:(id)target action:(SEL)action
{
    UIImage *imgNormal = [UIImage imageNamed:strImg];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:imgNormal forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:(strImgHighlight ? strImgHighlight : strImg)] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:(strImgSelected ? strImgSelected : strImg)] forState:UIControlStateSelected];
    
    CGFloat fDeltaWidth = ([[self class] barBtnSize].width - imgNormal.size.width)/2.0f;
    CGFloat fDeltaHeight = ([[self class] barBtnSize].height - imgNormal.size.height)/2.0f;
    fDeltaWidth = (fDeltaWidth >= 2.0f) ? fDeltaWidth/2.0f : 0.0f;
    fDeltaHeight = (fDeltaHeight >= 2.0f) ? fDeltaHeight/2.0f : 0.0f;
    [btn setImageEdgeInsets:UIEdgeInsetsMake(fDeltaHeight, fDeltaWidth, fDeltaHeight, fDeltaWidth)];
    
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(fDeltaHeight, imgNormal.size.width+10, fDeltaHeight, fDeltaWidth)];
    
    return btn;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _bIsBlur = NO;
        
        [self initUI];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initUI];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)initUI
{
    self.backgroundColor = [UIColor clearColor];
    
    // 默认左侧显示返回按钮
    _btnBack = [[self class] createNormalNaviBarBtnByTitle:@"返回" imgNormal:@"backBtn" imgHighlight:@"backBtn" target:self action:@selector(btnBack:)];
    
    _labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    _labelTitle.backgroundColor = [UIColor clearColor];
    _labelTitle.textColor = RGB_TitleNormal;
    _labelTitle.font = [UIFont systemFontOfSize:FLOAT_TitleSizeNormal];
    _labelTitle.textAlignment = NSTextAlignmentCenter;
    
    //导航栏背景
    _imgViewBg = [[UIImageView alloc] initWithFrame:self.bounds];
    _imgViewBg.image = [[UIImage imageNamed:@"NaviBarBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    _imgViewBg.alpha = 1.0f;
    UIImageView *bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, _imgViewBg.frame.size.height-0.5, UI_SCREEN_WIDTH, 0.5)];
    bottomLine.image = [UIImage imageNamed:@"line_horizontal_gray"];
    [_imgViewBg addSubview:bottomLine];
    
    if (_bIsBlur)
    {// iOS7可设置是否需要现实磨砂玻璃效果
        _imgViewBg.alpha = 0.0f;
        UINavigationBar *naviBar = [[UINavigationBar alloc] initWithFrame:self.bounds];
        [self addSubview:naviBar];
    }else{}
    
    _labelTitle.frame = [[self class] titleViewFrame];
    _imgViewBg.frame = self.bounds;
    
    [self addSubview:_imgViewBg];
    [self addSubview:_labelTitle];
    
    [self setBackBtn:_btnBack];
}

- (void)setTitle:(NSString *)strTitle
{
    [_labelTitle setText:strTitle];
}

- (void)setBackBtn:(UIButton *)btn
{
    if (_btnLeft)
    {
        [_btnLeft removeFromSuperview];
        _btnLeft = nil;
    }else{}
    
    _btnLeft = btn;
    if (_btnLeft)
    {
        _btnLeft.frame = Rect(0, 22.0f, 80.0, 40.0);
        [self addSubview:_btnLeft];
    }else{}
}

- (void)setLeftBtn:(UIButton *)btn
{
    if (_btnLeft)
    {
        [_btnLeft removeFromSuperview];
        _btnLeft = nil;
    }else{}
    
    _btnLeft = btn;
    if (_btnLeft)
    {
        _btnLeft.frame = Rect(0, 22.0f, [[self class] barBtnSize].width, [[self class] barBtnSize].height);
        [self addSubview:_btnLeft];
    }else{}
}

- (void)setRightBtn:(UIButton *)btn
{
    if (_btnRight)
    {
        [_btnRight removeFromSuperview];
        _btnRight = nil;
    }else{}
    
    _btnRight = btn;
    if (_btnRight)
    {
        _btnRight.frame = [[self class] rightBtnFrame];
        [self addSubview:_btnRight];
    }else{}
}

- (void)btnBack:(id)sender
{
    if (self.m_viewCtrlParent)
    {
        [self.m_viewCtrlParent.navigationController popViewControllerAnimated:YES];
    }else{APP_ASSERT_STOP}
}

- (void)showNetStateView {
    _labelTitle.frame = [[self class] titleViewFrameForNet];
    _netStateView = [[UIButton alloc] initWithFrame:CGRectMake((UI_SCREEN_WIDTH-190)/2, 45, 190, 14)];
    _netStateView.titleLabel.font = [UIFont systemFontOfSize:12];
    _netStateView.titleLabel.textAlignment = NSTextAlignmentCenter;
    _netStateView.titleLabel.textColor = [UIColor whiteColor];
    _netStateView.userInteractionEnabled = NO;
    [self addSubview:_netStateView];
}

- (void)setNetState:(int)state {
    if (state == netState_outDoor_4G) {
        [_netStateView setTitle:@"4G" forState:UIControlStateNormal];
    }else if (state == netState_outDoor_WIFI) {
        [_netStateView setImage:[UIImage imageNamed:@"Iphonewifi"] forState:UIControlStateNormal];
    }else if (state == netState_atHome_4G) {
        [_netStateView setTitle:@"4G" forState:UIControlStateNormal];
    }else if (state == netState_atHome_WIFI) {
        [_netStateView setImage:[UIImage imageNamed:@"Iphonewifi"] forState:UIControlStateNormal];
    }else if (state == netState_notConnect) {
        [_netStateView setTitle:@"未连接" forState:UIControlStateNormal];
    }
}

- (void)showCoverView:(UIView *)view
{
    [self showCoverView:view animation:NO];
}
- (void)showCoverView:(UIView *)view animation:(BOOL)bIsAnimation
{
    if (view)
    {
        [self hideOriginalBarItem:YES];
        
        [view removeFromSuperview];
        
        view.alpha = 0.4f;
        [self addSubview:view];
        if (bIsAnimation)
        {
            [UIView animateWithDuration:0.2f animations:^()
             {
                 view.alpha = 1.0f;
             }completion:^(BOOL f){}];
        }
        else
        {
            view.alpha = 1.0f;
        }
    }else{APP_ASSERT_STOP}
}

- (void)showCoverViewOnTitleView:(UIView *)view
{
    if (view)
    {
        if (_labelTitle)
        {
            _labelTitle.hidden = YES;
        }else{}
        
        [view removeFromSuperview];
        view.frame = _labelTitle.frame;
        
        [self addSubview:view];
    }else{APP_ASSERT_STOP}
}

- (void)hideCoverView:(UIView *)view
{
    [self hideOriginalBarItem:NO];
    if (view && (view.superview == self))
    {
        [view removeFromSuperview];
    }else{}
}

#pragma mark -
- (void)hideOriginalBarItem:(BOOL)bIsHide
{
    if (_btnLeft)
    {
        _btnLeft.hidden = bIsHide;
    }else{}
    if (_btnBack)
    {
        _btnBack.hidden = bIsHide;
    }else{}
    if (_btnRight)
    {
        _btnRight.hidden = bIsHide;
    }else{}
    if (_labelTitle)
    {
        _labelTitle.hidden = bIsHide;
    }else{}
}








@end