//
//  IpadFirstViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/5/22.
//  Copyright © 2017年 Brustar. All rights reserved.
// ipad的首页

#import "IpadFirstViewController.h"
#import "BaseTabBarController.h"
#import "VoiceOrderController.h"
#import <ImageIO/ImageIO.h>
#import "LeftViewController.h"

#define ANIMATION_TIME 1

@interface IpadFirstViewController ()<RCIMReceiveMessageDelegate,UIGestureRecognizerDelegate,LeftViewControllerDelegate,HttpDelegate,TcpRecvDelegate>
@property (nonatomic,strong) BaseTabBarController *baseTabbarController;
@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, readonly) UIButton *naviLeftBtn;
@property (nonatomic, readonly) UIButton *naviMiddletBtn;
@property (nonatomic,strong) NSString * weekStr;
@property (weak, nonatomic) IBOutlet UIView *MessageView;//聊天的视图
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;//显示未读消息的Label
@property (weak, nonatomic) IBOutlet UIButton *MessageBtnDo;//点击弹出聊天页面的按钮
@property (weak, nonatomic) IBOutlet UILabel *TimerLabel;//显示日期的label
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;//温度
@property (weak, nonatomic) IBOutlet UILabel *weekDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;//地方名字的显示
@property (nonatomic,strong) NSMutableArray * unreadcountArr;
@property (weak, nonatomic) IBOutlet UIView *CoverView;
@property (nonatomic,strong) NSString * WeekDayStr;
@property (nonatomic,strong) NSString * locationString;
@property (nonatomic,assign) int sum;
@property (weak, nonatomic) IBOutlet UIButton * firstBtn;
@property (weak, nonatomic) IBOutlet UIButton * TwoBtn;
@property (weak, nonatomic) IBOutlet UIButton * ThreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *VoiceBtn;//点击进入语音
@property (nonatomic,assign) int result;
@property (weak, nonatomic) IBOutlet UILabel *remindLabel;//每日提醒的label

@property (weak, nonatomic) IBOutlet UILabel *FamilyMenberLabel;//家庭成员Label

@property (weak, nonatomic) IBOutlet UILabel *messageLabel1;//第一个显示消息的label
@property (weak, nonatomic) IBOutlet UIImageView *Icone1Image;//第一个消息的头像

@property (weak, nonatomic) IBOutlet UILabel *messageLabel2;//第二个显示消息的label
@property (nonatomic,strong) NSMutableArray * bgmusicIDS;
@property (weak, nonatomic) IBOutlet UIImageView *IconeImage2;//第二个消息的头像
@property (weak, nonatomic) IBOutlet UIImageView *DUPImageView;//闪烁提醒的图标
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *threeBtnleading;
@property (nonatomic,strong) NSString * weahter;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (nonatomic,assign) NSTimer *scheculer;

@end

@implementation IpadFirstViewController
-(NSMutableArray *)unreadcountArr
{
    if (!_unreadcountArr) {
        _unreadcountArr = [NSMutableArray array];
    }
    
    return _unreadcountArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifications];
    [self connect];
    self.imageView.userInteractionEnabled = YES;
    self.messageLabel.layer.cornerRadius = self.messageLabel.bounds.size.width/2;
    self.messageLabel.layer.masksToBounds = YES;
     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap:)];
    [self.imageView addGestureRecognizer:tap];
    [self showNetStateView];
//    [self showMassegeLabel];
    [self setTimer];
    [self getWeekdayStringFromDate];
    [self chatConnect];
    //开启网络状况监听器
    [self updateInterfaceWithReachability];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bigMap:)];
    recognizer.delegate = self;
    [self.CoverView addGestureRecognizer:recognizer];
    
    self.scheculer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timing:) userInfo:nil repeats:YES];
    
 
   
}
-(void)creatItemID
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/notify.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{@"token":auothorToken,@"optype":[NSNumber numberWithInteger:2]};
        HttpManager *http=[HttpManager defaultManager];
        http.tag = 2;
        http.delegate = self;
        [http sendPost:url param:dict];
    }
}

-(IBAction)timing:(id)sender
{
    int unread = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
    if (unread>0) {
        self.DUPImageView.hidden=!self.DUPImageView.hidden;
    }
}
-(void)bigMap:(UITapGestureRecognizer *)ttp
{
        self.CoverView.hidden = YES;
         self.MessageView.hidden = YES;
    _baseTabbarController.tabbarPanel.hidden = NO;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.MessageView]) {
        return NO;
    }
    
    return YES;
}

- (void)connect
{
    SocketManager *sock = [SocketManager defaultManager];
    if ([[UD objectForKey:@"HostType"] intValue]) {
        [sock connectUDP:[IOManager C4Port]];
    }else{
        [sock connectUDP:[IOManager crestronPort]];
    }
    sock.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    _baseTabbarController.tabbarPanel.hidden = NO;
    _baseTabbarController.tabBar.hidden = YES;
    int unread = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
    
    self.messageLabel.text = [NSString stringWithFormat:@"%d" ,unread<0?0:unread];
    self.FamilyMenberLabel.text = [NSString stringWithFormat:@"家庭成员（%@）",[UD objectForKey:@"familyNum"]];
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    _bgmusicIDS = [[NSMutableArray alloc] init];
    NSArray * roomArr = [SQLManager getAllRoomsInfo];
    for (int i = 0; i < roomArr.count; i ++) {
        Room * roomName = roomArr[i];
        if (![SQLManager isWholeHouse:roomName.rId]) {
            self.deviceid = [SQLManager singleDeviceWithCatalogID:bgmusic byRoom:roomName.rId];
        }
        if (self.deviceid.length != 0) {
            [_bgmusicIDS addObject:self.deviceid];
            //查询设备状态
            NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
        
    }
    
   
    if (unread == 0) {
        self.messageLabel2.text = [NSString stringWithFormat:@"%@" , @"暂无新消息"];
        self.messageLabel1.text = @"";
//        self.Icone1Image.hidden = YES;
//        self.IconeImage2.hidden = YES;
        
    }else{
        self.Icone1Image.hidden = NO;
        self.IconeImage2.hidden = NO;
    }
    NSArray *history = [[RCIMClient sharedRCIMClient] getHistoryMessages:ConversationType_GROUP targetId:[[UD objectForKey:@"HostID"] description] oldestMessageId:[[UD objectForKey:@"messageid"] longValue] count:2];
    if ([history count]>1) {
        RCMessage *m1 = [history lastObject];
        RCMessage *m2 = [history firstObject];
        
        NSArray *info = [SQLManager queryChat:m1.senderUserId];
        NSString *nickname = [info firstObject];
        NSString *protrait = [info lastObject];
        NSString *tip=@"您有新消息";
        if ([m1.objectName isEqualToString:RCTextMessageTypeIdentifier]) {
            tip = m1.content.conversationDigest;
        }
        self.messageLabel1.text = [NSString stringWithFormat:@"%@ : %@" , nickname, tip];
        [self.Icone1Image sd_setImageWithURL:[NSURL URLWithString:protrait] placeholderImage:[UIImage imageNamed:@"logo"] options:SDWebImageRetryFailed];
        
        info = [SQLManager queryChat:m2.senderUserId];
        nickname = [info firstObject];
        protrait = [info lastObject];
        
        if ([m2.objectName isEqualToString:RCTextMessageTypeIdentifier]) {
            tip = m2.content.conversationDigest;
        }
        self.messageLabel2.text =[NSString stringWithFormat:@"%@ : %@" , nickname, tip];
        [self.IconeImage2 sd_setImageWithURL:[NSURL URLWithString:protrait] placeholderImage:[UIImage imageNamed:@"logo"] options:SDWebImageRetryFailed];
    }
    [self getScenesFromPlist];
    [self setBtn];
    [self getPlist];
    [self getWeather];
//    [self creatItemID];
    
    _sum = 0;
    for (int i = 0; i < self.unreadcountArr.count; i ++) {
        _sum += [self.unreadcountArr[i] integerValue];
        
    }
    [NC postNotificationName:@"SumNumber" object:[NSString stringWithFormat:@"%d",_sum]];
    
 ////////////////////////////////////// Mask View /////////////////////////////////////////
    NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageChatBtn];
    if (KeyStr.length <=0) {
        [LoadMaskHelper showMaskWithType:HomePageChatBtn onView:self.tabBarController.view delay:0.5 delegate:self];
    }else {
        NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageEnterChat];
        if (KeyStr.length <=0) {
            [LoadMaskHelper showMaskWithType:HomePageEnterChat onView:self.tabBarController.view delay:0.5 delegate:self];
        }else {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageEnterFamily];
            if(KeyStr.length <=0) {
                [LoadMaskHelper showMaskWithType:HomePageEnterFamily onView:self.tabBarController.view delay:0.5 delegate:self];
            }else {
                NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageScene];
                if(KeyStr.length <=0){
                    [LoadMaskHelper showMaskWithType:HomePageScene onView:self.tabBarController.view delay:0.5 delegate:self];
                }else {
                    NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageDevice];
                    if(KeyStr.length <=0){
                        [LoadMaskHelper showMaskWithType:HomePageDevice onView:self.tabBarController.view delay:0.5 delegate:self];
                    }else {
                        NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageCloud];
                        if(KeyStr.length <=0){
                            [LoadMaskHelper showMaskWithType:HomePageCloud onView:self.tabBarController.view delay:0.5 delegate:self];
                        }
                    }
                }
            }
        }
    }
     [self setupNaviBar];
}

-(void)getWeather
{
    NSString *url = [NSString stringWithFormat:@"%@cloud/weather.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{@"token":auothorToken,@"code":@"shenzhen"};
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dict showProgressHUD:NO];
    }
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue]==0)
        {
//            NSString * temp1 = responseObject[@"temp1"];
//            NSString * temp2 = responseObject[@"temp2"];
            NSString * temperature_curr = responseObject[@"temperature_curr"];
//            NSString * weather = responseObject[@"weather"];
            NSString * weather_curr = responseObject[@"weather_curr"];
            self.weahter = weather_curr;
            self.temperatureLabel.text = [NSString stringWithFormat:@"当前%@",temperature_curr];
             if ([weather_curr rangeOfString:@"多云"].location != NSNotFound ||[weather_curr rangeOfString:@"阴"].location != NSNotFound) {
                 self.imageView.image = [UIImage imageNamed:@"IpadSceneBg-Overcast"];
             }else if([weather_curr rangeOfString:@"雨"].location != NSNotFound) {
                 self.imageView.image = [UIImage imageNamed:@"IpadSceneBg-rain"];
             }else if ([weather_curr rangeOfString:@"雪"].location != NSNotFound) {
                 self.imageView.image = [UIImage imageNamed:@"IpadSceneBg-snow"];
             }else if ([weather_curr rangeOfString:@"雾霾"].location != NSNotFound) {
                 self.imageView.image = [UIImage imageNamed:@"IpadSceneBg-haze"];
             }else if([weather_curr rangeOfString:@"晴"].location != NSNotFound) {
                 if(_result>0){
                     self.imageView.image = [UIImage imageNamed:@"IpadSceneBg-night"];
                 }else{
                      self.imageView.image = [UIImage imageNamed:@"IpadSceneBg"];
                 }
             }
            
        }else{
            [MBProgressHUD showError:responseObject[@"保存失败"]];
        }
        
    } if (tag == 2) {
        if ([responseObject[@"result"] intValue]==0)
        {
            
            NSArray *dic = responseObject[@"notify_type_list"];
            
            if ([dic isKindOfClass:[NSArray class]]) {
                for(NSDictionary *dicDetail in dic)
                {
                    
                    [self.unreadcountArr addObject:dicDetail[@"unreadcount"]];
                }
            }
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
        
    }
    
}

-(void)getPlist
{
    NSArray  *paths  =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *filePath = [docDir stringByAppendingPathComponent:@"Title.plist"];
    NSString *filePath1 = [docDir stringByAppendingPathComponent:@"Detail.plist"];
    NSArray * TitleArray = [[NSArray alloc] initWithContentsOfFile:filePath];
    NSArray * DetailArray = [[NSArray alloc] initWithContentsOfFile:filePath1];
    NSMutableSet *titleSet = [[NSMutableSet alloc] init];
    NSMutableSet *DetailSet = [[NSMutableSet alloc] init];
    if (TitleArray.count!=0) {
        while ([titleSet count] < 1) {
            int r = arc4random() % [TitleArray count];
            [titleSet addObject:[TitleArray objectAtIndex:r]];
        }
        NSArray * title = [titleSet allObjects];
        NSString * SubStr  = title[0];
        while ([DetailSet count] < 1) {
            int r = arc4random() % [DetailArray count];
            [DetailSet addObject:[DetailArray objectAtIndex:r]];
        }
        NSArray * detail = [DetailSet allObjects];
        NSString * SupStr = detail[0];
        self.remindLabel.text = [NSString stringWithFormat:@"%@%@!",SubStr,SupStr];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    _baseTabbarController.tabbarPanel.hidden = NO;
    _baseTabbarController.tabBar.hidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)getScenesFromPlist
{
    _shortcutsArray = [[NSMutableArray alloc] init];
    NSString *shortcutsPath = [[IOManager sceneShortcutsPath] stringByAppendingPathComponent:@"sceneShortcuts.plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:shortcutsPath];
    if (dictionary) {
        NSArray *scenesArray = dictionary[@"Scenes"];
        if (scenesArray && [scenesArray isKindOfClass:[NSArray class]]) {
            for (NSDictionary *scene in scenesArray) {
                if ([scene isKindOfClass:[NSDictionary class]]) {
                    Scene *info = [[Scene alloc] init];
                    info.sceneID = [scene[@"sceneID"] intValue];
                    info.sceneName = scene[@"sceneName"];
                    info.roomID = [scene[@"roomID"] intValue];
                    info.roomName = scene[@"roomName"];
                    
                    [_shortcutsArray addObject:info];
                }
            }
        }
    }
}

-(void)setBtn
{
    _firstBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    _TwoBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    _ThreeBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    if (_shortcutsArray.count != 0) {
        if (_shortcutsArray.count == 1) {
            _info1 = _shortcutsArray[0];
            [_firstBtn setTitle:_info1.sceneName forState:UIControlStateNormal];
            _firstBtn.titleLabel.font = [UIFont systemFontOfSize:10];
            _firstBtn.hidden = NO;
            _TwoBtn.hidden = YES;
            _ThreeBtn.hidden = NO;
            [_ThreeBtn setTitle:@"" forState:UIControlStateNormal];
            [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular4"] forState:UIControlStateNormal];
             self.threeBtnleading.constant = 40;
        }if(_shortcutsArray.count == 2) {
            _info1 = _shortcutsArray[0];
            _info2 = _shortcutsArray[1];
            [_firstBtn setTitle:_info1.sceneName forState:UIControlStateNormal];
            [_TwoBtn setTitle:_info2.sceneName forState:UIControlStateNormal];
            _firstBtn.hidden = NO;
            _TwoBtn.hidden = NO;
            _ThreeBtn.hidden = NO;
            [_ThreeBtn setTitle:@"" forState:UIControlStateNormal];
            [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular4"] forState:UIControlStateNormal];
             self.threeBtnleading.constant = 40;
            
        }if (_shortcutsArray.count == 3) {
            _info1 = _shortcutsArray[0];
            _info2 = _shortcutsArray[1];
            _info3 = _shortcutsArray[2];
            [_firstBtn setTitle:_info1.sceneName forState:UIControlStateNormal];
            [_TwoBtn setTitle:_info2.sceneName forState:UIControlStateNormal];
            [_ThreeBtn setTitle:_info3.sceneName forState:UIControlStateNormal];
            [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular3"] forState:UIControlStateNormal];
            _firstBtn.hidden = NO;
            _TwoBtn.hidden = NO;
            _ThreeBtn.hidden = NO;
             self.threeBtnleading.constant = 40;
        }
    }else{
       
        [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular4"] forState:UIControlStateNormal];
        [_ThreeBtn setTitle:@"" forState:UIControlStateNormal];
        _firstBtn.hidden = YES;
        _TwoBtn.hidden = YES;
        _ThreeBtn.hidden = NO;
        self.threeBtnleading.constant = -60;
        
    }
}
//点击首页跳转到家庭首页
-(void)doTap:(UIGestureRecognizer *)dap
{
    // 设定位置和大小
    CGRect frame = CGRectMake(0,0,UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
    // 读取gif图片数据
    NSString *launchAnimation;

    if ([self.weahter rangeOfString:@"多云"].location != NSNotFound ||[self.weahter rangeOfString:@"阴"].location != NSNotFound) {
        launchAnimation = @"cloudy";
    }else if([self.weahter rangeOfString:@"雨"].location != NSNotFound) {
        launchAnimation = @"rain";
    }else if  ([self.weahter rangeOfString:@"雪"].location != NSNotFound) {
        launchAnimation = @"snowing";
    }else if ([self.weahter rangeOfString:@"雾霾"].location != NSNotFound) {
        launchAnimation = @"haze";
    }else if([self.weahter rangeOfString:@"晴"].location != NSNotFound) {
            if(_result>0){
                launchAnimation = @"night";
            }else{
                launchAnimation = @"ipadFirstViewVC";
            }
    }
    
    //test uiimageview
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:launchAnimation withExtension:@"gif"]; //加载GIF图片
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef) fileUrl, NULL); //将GIF图片转换成对应的图片源
    size_t frameCout = CGImageSourceGetCount(gifSource); //获取其中图片源个数，即由多少帧图片组成
    NSMutableArray *frames = [[NSMutableArray alloc] init]; //定义数组存储拆分出来的图片
    for (size_t i = 0; i < frameCout; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL); //从GIF图片中取出源图片
        UIImage *imageName = [UIImage imageWithCGImage:imageRef];//将图片源转换成UIimageView能使用的图片源
        [frames addObject:imageName]; //将图片加入数组中
        CGImageRelease(imageRef);
    }
    UIImageView *gifImageView = [[UIImageView alloc] initWithFrame:frame];
    gifImageView.animationImages = frames; //将图片数组加入UIImageView动画数组中
    gifImageView.animationDuration = ANIMATION_TIME;//每次动画时长
    [gifImageView setAnimationRepeatCount:1];
    [gifImageView startAnimating];
    [self.view addSubview:gifImageView];
    
    CFRelease(gifSource);
    [self performSelector:@selector(doOtherAction) withObject:nil afterDelay:ANIMATION_TIME];

}

-(void)doOtherAction{
    
    UIStoryboard *planeGraphStoryBoard  = [UIStoryboard storyboardWithName:@"PlaneGraph" bundle:nil];
    PlaneGraphViewController *planeGraphVC = [planeGraphStoryBoard instantiateViewControllerWithIdentifier:@"PlaneGraphVC"];
    [self.navigationController pushViewController:planeGraphVC animated:NO];
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(netWorkDidChangedNotification:) name:@"NetWorkDidChangedNotification" object:nil];
    [NC addObserver:self selector:@selector(SumNumber:) name:@"SumNumber" object:nil];
    [NC addObserver:self selector:@selector(loginExpiredNotification:) name:@"LoginExpiredNotification" object:nil];//登录过期的通知
}

- (void)loginExpiredNotification:(NSNotification *)noti {
    [UD removeObjectForKey:@"AuthorToken"];
    [UD synchronize];
    [[SocketManager defaultManager] cutOffSocket];
    
    [self gotoLoginViewController];
}

- (void)gotoLoginViewController {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"loginNavController"];//进入登录页面
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.window.rootViewController = vc;
    [appDelegate.window makeKeyAndVisible];
}

- (void)netWorkDidChangedNotification:(NSNotification *)noti {
    [self refreshUI];
}
-(void)SumNumber:(NSNotification *)no
{
    NSString * sumNumber = no.object;
    _sum = [sumNumber intValue];
    
    if (_sum != 0) {
        [self showMassegeLabel];
    }
}
- (void)refreshUI {
    DeviceInfo *info = [DeviceInfo defaultManager];
    if([[AFNetworkReachabilityManager sharedManager] isReachableViaWWAN]) { //手机自带网络
        if (info.connectState == offLine) {
            [self setNetState:netState_notConnect];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage  imageNamed:@"slider"] forState:UIControlStateNormal];
            NSLog(@"离线模式");
        }else{
            [self setNetState:netState_outDoor_4G];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
            NSLog(@"外出模式-4G");
        }
    }else if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) { //WIFI
        
        if (info.connectState == atHome) {
            [self setNetState:netState_atHome_WIFI];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
            NSLog(@"在家模式-WIFI");
            
            
        }else if (info.connectState == outDoor){
            [self setNetState:netState_outDoor_WIFI];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
            NSLog(@"外出模式-WIFI");
            
        }else if (info.connectState == offLine) {
            [self setNetState:netState_notConnect];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
            NSLog(@"离线模式");
        }
        
    }else {
        [self setNetState:netState_notConnect];
        [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
        NSLog(@"离线模式");
    }
}
//处理连接改变后的情况
- (void)updateInterfaceWithReachability
{
    __block IpadFirstViewController * FirstBlockSelf = self;
    
    _afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    
    [_afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        DeviceInfo *info = [DeviceInfo defaultManager];
        if(status == AFNetworkReachabilityStatusReachableViaWWAN) //手机自带网络
        {
            if (info.connectState == offLine) {
                [FirstBlockSelf setNetState:netState_notConnect];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage  imageNamed:@"slider"] forState:UIControlStateNormal];
                NSLog(@"离线模式");
            }else{
                [FirstBlockSelf setNetState:netState_outDoor_4G];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                NSLog(@"外出模式-4G");
            }
        }
        else if(status == AFNetworkReachabilityStatusReachableViaWiFi) //WIFI
        {
            if (info.connectState == atHome) {
                [FirstBlockSelf setNetState:netState_atHome_WIFI];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                NSLog(@"在家模式-WIFI");
                
                
            }else if (info.connectState == outDoor){
                [FirstBlockSelf setNetState:netState_outDoor_WIFI];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                NSLog(@"外出模式-WIFI");
                
            }else if (info.connectState == offLine) {
                [FirstBlockSelf setNetState:netState_notConnect];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
                NSLog(@"离线模式");
                
                
            }
        }else if(status == AFNetworkReachabilityStatusNotReachable){ //没有网络(断网)
            [FirstBlockSelf setNetState:netState_notConnect];
            [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
            NSLog(@"离线模式");
            
        }else if (status == AFNetworkReachabilityStatusUnknown) { //未知网络
            [FirstBlockSelf setNetState:netState_notConnect];
            [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
            NSLog(@"离线模式");
            
        }
    }];
    
    [_afNetworkReachabilityManager startMonitoring];//开启网络监视器；
    
}
- (void)setupNaviBar {
    
   [self setNaviBarTitle:[UD objectForKey:@"homename"]]; //设置标题
    _naviMiddletBtn = [[UIButton alloc] init];
//    [_naviMiddletBtn setTitle:[UD objectForKey:@"homename"] forState:UIControlStateNormal];
//    [_naviMiddletBtn addTarget:self action:@selector(MiddleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _naviLeftBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"clound_white" imgHighlight:@"clound_white" target:self action:@selector(leftBtnClicked:)];
    
    NSString *music_icon = nil;
    NSInteger isPlaying = [[UD objectForKey:@"IsPlaying"] integerValue];
    if (isPlaying) {
        music_icon = @"Ipad-NowMusic-red";
    }else {
        music_icon = @"Ipad-NowMusic";
    }
    
    _naviRightBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:music_icon imgHighlight:music_icon target:self action:@selector(rightBtnClicked:)];
    if (isPlaying) {
        UIImageView * imageView = _naviRightBtn.imageView ;
        
        imageView.animationImages = [NSArray arrayWithObjects:
                                     [UIImage imageNamed:@"Ipad-NowMusic-red2"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red3"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red4"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red5"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red6"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red7"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red8"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red9"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red10"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red11"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red12"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red13"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red14"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red15"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red16"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red17"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red18"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red19"],
                                     
                                     nil];
        
        //设置动画总时间
        imageView.animationDuration = 2.0;
        //设置重复次数，0表示无限
        imageView.animationRepeatCount = 0;
        //开始动画
        if (! imageView.isAnimating) {
            [imageView startAnimating];
        }
    }
    [self setNaviBarLeftBtn:_naviLeftBtn];
    [self setNaviBarRightBtn:_naviRightBtn];
//    [self setNaviMiddletBtn:_naviMiddletBtn];:(NSDate*)inputDate
}
-(void)rightBtnClicked:(UIButton *)btn
{
    NSInteger isPlaying = [[UD objectForKey:@"IsPlaying"] integerValue];
    if (isPlaying == 0) {
        [MBProgressHUD showError:@"没有正在播放的设备"];
        return;
    }
    
    
    UIStoryboard * HomeStoryBoard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    
    if (_nowMusicController == nil) {
        _nowMusicController = [HomeStoryBoard instantiateViewControllerWithIdentifier:@"NowMusicController"];
        _nowMusicController.delegate = self;
        [self.view addSubview:_nowMusicController.view];
    }else {
        [_nowMusicController.view removeFromSuperview];
        _nowMusicController = nil;
    }

}

- (void)onBgButtonClicked:(UIButton *)sender {
    if (_nowMusicController) {
        [_nowMusicController.view removeFromSuperview];
        _nowMusicController = nil;
    }
}
- (void)leftBtnClicked:(UIButton *)btn {
    
    self.MessageView.hidden = YES;
    self.CoverView.hidden = YES;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        iPadMyViewController *myVC = [[iPadMyViewController alloc] init];
        [self.navigationController pushViewController:myVC animated:YES];
    }else {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if (appDelegate.LeftSlideVC.closed)
        {
            [appDelegate.LeftSlideVC openLeftView];
        }
        else
        {
            [appDelegate.LeftSlideVC closeLeftView];
        }
    }
   
    
}
-(void)getWeekdayStringFromDate {
    
    
    NSDate*date = [NSDate date];
    NSCalendar*calendar = [NSCalendar currentCalendar];
    NSDateComponents*comps;
    comps =[calendar components:(NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)
            
                       fromDate:date];
    NSInteger weekday = [comps weekday]; // 星期几（注意，周日是“1”，周一是“2”。。。。）
    if (weekday == 1) {
        self.WeekDayStr = @"周日";
    }if (weekday == 2) {
        self.WeekDayStr = @"周一";
    }if (weekday == 3) {
        self.WeekDayStr = @"周二";
    }if (weekday == 4) {
        self.WeekDayStr = @"周三";
    }if (weekday == 5) {
        self.WeekDayStr = @"周四";
    }if (weekday == 6) {
        self.WeekDayStr = @"周五";
    }if (weekday == 7) {
        self.WeekDayStr = @"周六";
    }
    self.weekDayLabel.text = self.WeekDayStr;
    
}
-(void)setTimer
{
    //获取系统时间
    NSDate * senddate=[NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH:mm"];
    _locationString=[dateformatter stringFromDate:senddate];
    _result= [_locationString compare:@"19:00"];
    NSCalendar * cal=[NSCalendar currentCalendar];
    NSUInteger unitFlags=NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:senddate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month];
    NSInteger day=[conponent day];
    self.TimerLabel.text = [NSString stringWithFormat:@"%ld.%ld.%ld",(long)year,(long)month,(long)day];

}

- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left
{
    [IOManager writeUserdefault:@(message.messageId) forKey:@"messageid"];
    NSArray *info = [SQLManager queryChat:message.senderUserId];
    NSString *nickname = [info firstObject];
    NSString *protrait = [info lastObject];
    int unread = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
    NSString *tip=@"您有新消息";
    if ([message.objectName isEqualToString:RCTextMessageTypeIdentifier]) {
        tip = message.content.conversationDigest;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.messageLabel1.text = self.messageLabel2.text;
        self.messageLabel2.text =[NSString stringWithFormat:@"%@ : %@" , nickname, tip];
        self.messageLabel.text = [NSString stringWithFormat:@"%d" ,unread<0?0:unread];
        if (unread == 0) {
            self.messageLabel2.text = [NSString stringWithFormat:@"%@" , @"暂无新消息"];
            self.messageLabel1.text = @"";
            self.Icone1Image.hidden = YES;
            self.IconeImage2.hidden = YES;
            
        }else{
            self.Icone1Image.hidden = NO;
            self.IconeImage2.hidden = NO;
        }
        self.Icone1Image.image = self.IconeImage2.image;
        [self.IconeImage2 sd_setImageWithURL:[NSURL URLWithString:protrait] placeholderImage:[UIImage imageNamed:@"logo"] options:SDWebImageRetryFailed];
    });
    
}

-(void) chatConnect
{
    NSString *token = [UD objectForKey:@"rctoken"];
    [[RCIM sharedRCIM] connectWithToken:token success:^(NSString *userId) {
        NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
        [RCIM sharedRCIM].receiveMessageDelegate=self;
        if ([[DeviceInfo defaultManager] pushToken]) {
            [[RCIMClient sharedRCIMClient] setDeviceToken:[[DeviceInfo defaultManager] pushToken]];
        }
    } error:nil tokenIncorrect:nil];
}

//进入聊天页面
-(void)setRCIM
{
    NSString *groupID = [[UD objectForKey:@"HostID"] description];
    NSString *homename = [UD objectForKey:@"homename"];
    RCGroup *aGroupInfo = [[RCGroup alloc]initWithGroupId:groupID groupName:homename portraitUri:@""];
    ConversationViewController *conversationVC = [[ConversationViewController alloc] init];
    conversationVC.conversationType = ConversationType_GROUP;
    conversationVC.targetId = aGroupInfo.groupId;
    [conversationVC setTitle: [NSString stringWithFormat:@"%@",aGroupInfo.groupName]];
    RCUserInfo *user = [[RCIM sharedRCIM] currentUserInfo];
    NSArray *info = [SQLManager queryChat:user.userId];
    NSString *nickname = [info firstObject];
    NSString *protrait = [info lastObject];
    [[RCIM sharedRCIM] refreshUserInfoCache:[[RCUserInfo alloc] initWithUserId:user.userId name:nickname portrait:protrait] withUserId:user.userId];
    [self.navigationController pushViewController:conversationVC animated:YES];
}

//弹出聊天框
- (IBAction)MessageBtnDo:(id)sender {
    
    _baseTabbarController.tabbarPanel.hidden = YES;
    if (self.CoverView.hidden) {
        self.CoverView.hidden = NO;
        self.MessageView.hidden = NO;
    }else{
        self.CoverView.hidden = YES;
        self.MessageView.hidden = YES;
        _baseTabbarController.tabbarPanel.hidden = NO;
//        self.chatlabel.text = @"456";
    }
}

//回复消息的按钮
- (IBAction)replyBtn:(id)sender {
    
    [self setRCIM];
}

- (IBAction)FirstBtn:(id)sender {
    _firstBtn.selected = !_firstBtn.selected;
    if (_firstBtn.selected) {
        [_firstBtn setBackgroundImage:[UIImage imageNamed:@"circular2"] forState:UIControlStateSelected];
        [_firstBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[SceneManager defaultManager] startScene:_info1.sceneID];
        [SQLManager updateSceneStatus:1 sceneID:_info1.sceneID];//更新数据库
    }else{
        [_firstBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_firstBtn setBackgroundImage:[UIImage imageNamed:@"circular3"] forState:UIControlStateNormal];
        [[SceneManager defaultManager] poweroffAllDevice:_info1.sceneID];
        [SQLManager updateSceneStatus:0 sceneID:_info1.sceneID];//更新数据库
    }
}

- (IBAction)TwoBtn:(id)sender {
    _TwoBtn.selected = !_TwoBtn.selected;
    if (_TwoBtn.selected) {
        [_TwoBtn setBackgroundImage:[UIImage imageNamed:@"circular2"] forState:UIControlStateSelected];
        [_TwoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[SceneManager defaultManager] startScene:_info2.sceneID];
        [SQLManager updateSceneStatus:1 sceneID:_info2.sceneID];//更新数据库
    }else{
        [_TwoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_TwoBtn setBackgroundImage:[UIImage imageNamed:@"circular3"] forState:UIControlStateNormal];
        [[SceneManager defaultManager] poweroffAllDevice:_info2.sceneID];
        [SQLManager updateSceneStatus:0 sceneID:_info2.sceneID];//更新数据库
    }
    
}
- (IBAction)ThreeBtn:(id)sender {
    _ThreeBtn.selected = !_ThreeBtn.selected;
    if ([_ThreeBtn.currentTitle isEqualToString:@""]) {
        self.MessageView.hidden = YES;
        self.CoverView.hidden = YES;
        UIStoryboard * myInfoStoryBoard = [UIStoryboard storyboardWithName:@"MyInfo" bundle:nil];
        SceneShortcutsViewController * shortcutKeyVC = [myInfoStoryBoard instantiateViewControllerWithIdentifier:@"SceneShortcutsVC"];
        [self.navigationController pushViewController:shortcutKeyVC animated:YES];
    }else{
        if (_ThreeBtn.selected) {
            [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular2"] forState:UIControlStateSelected];
            [_ThreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [[SceneManager defaultManager] startScene:_info3.sceneID];
            [SQLManager updateSceneStatus:1 sceneID:_info3.sceneID];//更新数据库
        }else{
            [_ThreeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular3"] forState:UIControlStateNormal];
            [[SceneManager defaultManager] poweroffAllDevice:_info3.sceneID];
            [SQLManager updateSceneStatus:0 sceneID:_info3.sceneID];//更新数据库
        }
    }
    
}
- (IBAction)VoiceBtn:(id)sender {
    
    UIStoryboard * iphoneStoryBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    VoiceOrderController * voiceVC = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"VoiceOrderController"];
    
    [self.navigationController pushViewController:voiceVC animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self.scheculer invalidate];
}

#pragma mark - SingleMaskViewDelegate
- (void)onNextButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    if (pageType == HomePageChatBtn) {
        _baseTabbarController.tabbarPanel.hidden = YES;
        if (self.CoverView.hidden) {
            self.CoverView.hidden = NO;
            self.MessageView.hidden = NO;
        }else{
            self.CoverView.hidden = YES;
            self.MessageView.hidden = YES;
            _baseTabbarController.tabbarPanel.hidden = NO;
            //        self.chatlabel.text = @"456";
        }
        
        [LoadMaskHelper showMaskWithType:HomePageEnterChat onView:self.tabBarController.view delay:0.5 delegate:self];
    }else if (pageType == HomePageEnterChat) {
        self.CoverView.hidden = YES;
        self.MessageView.hidden = YES;
        _baseTabbarController.tabbarPanel.hidden = NO;
        [self setRCIM];
    }else if (pageType == HomePageEnterFamily) {
        UIStoryboard *planeGraphStoryBoard  = [UIStoryboard storyboardWithName:@"PlaneGraph" bundle:nil];
        PlaneGraphViewController *planeGraphVC = [planeGraphStoryBoard instantiateViewControllerWithIdentifier:@"PlaneGraphVC"];
        planeGraphVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:planeGraphVC animated:YES];
    }else if (pageType == HomePageScene) {
        [NC postNotificationName:@"TabbarPanelClickedNotification" object:nil];
        
    }else if (pageType == HomePageDevice) {
        [NC postNotificationName:@"TabbarPanelClickedNotificationDevice" object:nil];
        
    }else if (pageType == HomePageCloud) {
        iPadMyViewController *myVC = [[iPadMyViewController alloc] init];
        [self.navigationController pushViewController:myVC animated:YES];
    }
}

- (void)onSkipButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    
    if (pageType == HomePageChatBtn || pageType == HomePageEnterChat) {
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewHomePageChatBtn];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewHomePageEnterChat];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewChatView];
        [UD synchronize];
        
        self.CoverView.hidden = YES;
        self.MessageView.hidden = YES;
        
        [LoadMaskHelper showMaskWithType:HomePageEnterFamily onView:self.tabBarController.view delay:0.5 delegate:self];
        
        return;
    }
    
    if (pageType == HomePageEnterFamily) {
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewFamilyHome];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewFamilyHomeDetail];
        [UD synchronize];
        
        [LoadMaskHelper showMaskWithType:HomePageScene onView:self.tabBarController.view delay:0.5 delegate:self];
        return;
    }
    
    if (pageType == HomePageScene) {
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewSceneAdd];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewScene];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewSceneDetail];
        [UD synchronize];
        
        [LoadMaskHelper showMaskWithType:HomePageDevice onView:self.tabBarController.view delay:0.5 delegate:self];
        return;
    }
    
    if (pageType == HomePageDevice) {
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewDevice];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewDeviceAir];
        [UD synchronize];
        
        [LoadMaskHelper showMaskWithType:HomePageCloud onView:self.tabBarController.view delay:0.5 delegate:self];
        return;
    }
    
    if (pageType == HomePageCloud) {
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewLeftView];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewSettingView];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewAccessControl];
        [UD synchronize];
    }
    
}

- (void)onTransparentBtnClicked:(UIButton *)btn {
    if (btn.tag == 1) { //聊天按钮
        _baseTabbarController.tabbarPanel.hidden = YES;
        if (self.CoverView.hidden) {
            self.CoverView.hidden = NO;
            self.MessageView.hidden = NO;
        }else{
            self.CoverView.hidden = YES;
            self.MessageView.hidden = YES;
            _baseTabbarController.tabbarPanel.hidden = NO;
            //        self.chatlabel.text = @"456";
        }
        
        [LoadMaskHelper showMaskWithType:HomePageEnterChat onView:self.tabBarController.view delay:0.5 delegate:self];
    }else if (btn.tag == 2) { // 进入聊天
        self.CoverView.hidden = YES;
        self.MessageView.hidden = YES;
        _baseTabbarController.tabbarPanel.hidden = NO;
        [self setRCIM];
    }else if (btn.tag == 3) { //进入家庭
        UIStoryboard *planeGraphStoryBoard  = [UIStoryboard storyboardWithName:@"PlaneGraph" bundle:nil];
        PlaneGraphViewController *planeGraphVC = [planeGraphStoryBoard instantiateViewControllerWithIdentifier:@"PlaneGraphVC"];
        planeGraphVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:planeGraphVC animated:YES];
    }else if (btn.tag == 4) {  // 进入场景
        [NC postNotificationName:@"TabbarPanelClickedNotification" object:nil];
    }else if (btn.tag == 5) {  //进入设备
        [NC postNotificationName:@"TabbarPanelClickedNotificationDevice" object:nil];
    }else if (btn.tag == 6) {  //点击“云”
        iPadMyViewController *myVC = [[iPadMyViewController alloc] init];
        [self.navigationController pushViewController:myVC animated:YES];
    }
    
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    for (int i = 0; i < self.bgmusicIDS.count; i ++) {
        if (proto.cmd==0x01) {
            NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
            if ([devID intValue]==[self.bgmusicIDS[i] intValue]) {
                if (proto.action.state == PROTOCOL_VOLUME) {
                    NSLog(@"有音量");
                }if (proto.action.state == PROTOCOL_ON) {
                    NSLog(@"开启状态");
                    [IOManager writeUserdefault:@"1" forKey:@"IsPlaying"];
                }if (proto.action.state == PROTOCOL_OFF) {
                    NSLog(@"关闭状态");
                    [IOManager writeUserdefault:@"0" forKey:@"IsPlaying"];
                }
            }
        }
    }
      [self setupNaviBar];
}


@end
