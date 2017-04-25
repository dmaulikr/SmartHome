//
//  Light.m
//  SmartHome
//
//  Created by Brustar on 16/5/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "LightController.h"
#import "PackManager.h" 
#import "SocketManager.h"
#import "SQLManager.h"
#import "Device.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "SceneManager.h"
#import "YALContextMenuTableView.h"
#import "ContextMenuCell.h"
#import "ORBSwitch.h"

static NSString *const menuCellIdentifier = @"rotationCell";

@interface LightController ()<UITableViewDelegate,UITableViewDataSource,YALContextMenuTableViewDelegate,ORBSwitchDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *favButt;//收藏
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,assign) CGFloat brightValue;
@property (nonatomic,strong) NSMutableArray *lIDs;
@property (nonatomic,strong) NSMutableArray *lNames;
@property (nonatomic,strong) UIImageView *tranformView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentLight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segementTopConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewRightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLeftContraints;


@property (weak, nonatomic) IBOutlet UIView *lightView;
@property (weak, nonatomic) IBOutlet UIButton *sprightlierBtn;//明快
@property (weak, nonatomic) IBOutlet UIButton *peacefulBtn;//幽静
@property (weak, nonatomic) IBOutlet UIButton *romanceBtn;//浪漫
@property (weak, nonatomic) IBOutlet UISlider *lightSlider;//控制所有灯的亮度调节

@property (nonatomic,assign) int sceneID;
@property (nonatomic,strong) YALContextMenuTableView* contextMenuTableView;

@property (nonatomic, strong) NSArray *menuTitles;

- (IBAction)selectTypeOfLight:(UISegmentedControl *)sender;

@end

@implementation LightController

-(NSMutableArray *)lIDs
{
    if(!_lIDs)
    {
        _lIDs = [NSMutableArray array];
       
           if(self.sceneid > 0 && !self.isAddDevice)
           {
           
               NSArray *lightArr = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
               for(int i = 0; i <lightArr.count; i++)
               {
                   NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[lightArr[i] intValue]];
                   if([typeName isEqualToString:@"灯光"])
                   {
                       [_lIDs addObject:lightArr[i]];
                   }
               }
           }else if(self.roomID > 0){
               [_lIDs addObjectsFromArray:[SQLManager getDeviceByTypeName:SWITCHLIGHT_SUB_TYPE andRoomID:self.roomID]];
               [_lIDs addObjectsFromArray:[SQLManager getDeviceByTypeName:DIMMER_SUB_TYPE andRoomID:self.roomID]];
               [_lIDs addObjectsFromArray:[SQLManager getDeviceByTypeName:COLORLIGHT_SUB_TYPE andRoomID:self.roomID]];

           }else{
               [_lIDs addObject:self.deviceid?self.deviceid:@"0"];
           }
        
        }
    return _lIDs;
}

-(NSMutableArray *)lNames
{
    if(!_lNames)
    {
        _lNames = [NSMutableArray array];
        for(int i = 0; i < self.lIDs.count; i++)
        {
            int lID = [self.lIDs[i] intValue];
            NSString *name = [SQLManager deviceNameByDeviceID:lID];
            [_lNames addObject:name];
        }
    }
    return _lNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSwitch];
    self.detailCell = [[[NSBundle mainBundle] loadNibNamed:@"DetailTableViewCell" owner:self options:nil] lastObject];
    self.detailCell.bright.continuous = NO;
    [self.detailCell.bright addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    [self.detailCell.power addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    self.lightSlider.continuous = NO;
    self.cell = [[[NSBundle mainBundle] loadNibNamed:@"ColourTableViewCell" owner:self options:nil] lastObject];
    //[self setupSegmentLight];
    self.scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
    if ([self.sceneid intValue]>0) {
        _favButt.enabled=YES;
        
        [self syncUI];
    }
    self.tableView.scrollEnabled = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncLight:) name:@"light" object:nil];
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    [_lightSlider addTarget:self action:@selector(onLightSliderValueChanged:) forControlEvents:UIControlEventValueChanged];//所有灯的总控制
    _sprightlierBtn.layer.cornerRadius = 8.0;
    _sprightlierBtn.layer.masksToBounds = YES;
    _romanceBtn.layer.cornerRadius = 8.0;
    _romanceBtn.layer.masksToBounds = YES;
    _peacefulBtn.layer.cornerRadius = 8.0;
    _peacefulBtn.layer.masksToBounds = YES;
    if (_showLightView) {
        _lightView.hidden = NO;
    }else {
        _lightView.hidden = YES;
    }
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGRect frame1 = _sprightlierBtn.frame;
        frame1.origin.y += 20;
        _sprightlierBtn.frame = frame1;
        
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)onLightSliderValueChanged:(UISlider *)slider {
    
    [[SceneManager defaultManager] dimingScene:[self.sceneid intValue] brightness:(int)(slider.value*100)];
    self.detailCell.bright.value = slider.value;
    self.detailCell.valueLabel.text = [NSString stringWithFormat:@"%d%%", (int)(self.detailCell.bright.value * 100)];
    //self.detailCell.power.on = self.detailCell.bright.value >0;
    [self save:self.detailCell.bright];
    
}

-(void) syncUI
{
    for(id device in self.scene.devices)
    {
        if ([device isKindOfClass:[Light class]] && ((Light*)device).deviceID == [self.deviceid intValue]) {
            float brightness_f = (float)((Light *)device).brightness;
            self.detailCell.bright.value = brightness_f/100;
            _lightSlider.value = brightness_f/100;
            self.detailCell.valueLabel.text = [NSString stringWithFormat:@"%d%%", (int)(self.detailCell.bright.value * 100)];
            self.detailCell.power.on=((Light*)device).isPoweron;
            if ([((Light*)device).color count]>2) {
                self.cell.colourView.backgroundColor=[UIColor colorWithRed:[[((Light*)device).color firstObject] intValue]/255.0 green:[[((Light*)device).color objectAtIndex:1] intValue]/255.0  blue:[[((Light*)device).color lastObject] intValue]/255.0  alpha:1];
            }
        }
    }
}

-(IBAction)syncLight:(id)sender
{
    NSNotification * notice = (NSNotification *)sender;
    NSDictionary *dic= [notice userInfo];
    int state = [dic[@"state"] intValue];
    if (state == PROTOCOL_OFF || state == PROTOCOL_ON) {
        self.detailCell.power.on = (bool)state;
    }
    if (state == 0x0a) {
        self.detailCell.bright.value=[dic[@"r"] intValue];
    }
    if (state == 0x0b) {
        self.cell.colourView.backgroundColor=[UIColor colorWithRed:[dic[@"r"] intValue]/255.0 green:[dic[@"g"] intValue]/255.0  blue:[dic[@"b"] intValue]/255.0  alpha:1];
    }
}

- (void)setupSegmentLight
{
    if (self.lNames == nil) {
        return;
    }
    
    [self.segmentLight removeAllSegments];
    
    for ( int i = 0; i < self.lNames.count; i++) {
        [self.segmentLight insertSegmentWithTitle:self.lNames[i] atIndex:i animated:NO];
    }
    self.segmentLight.selectedSegmentIndex = 0;
    self.deviceid = [self.lIDs objectAtIndex:self.segmentLight.selectedSegmentIndex];
}

- (NSDictionary *)getRGBDictionaryByColor:(UIColor *)originColor
{
    CGFloat r=0,g=0,b=0,a=0;
    if ([originColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [originColor getRed:&r green:&g blue:&b alpha:&a];
    }
    else {
        const CGFloat *components = CGColorGetComponents(originColor.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    
    return @{@"R":@(r),
             @"G":@(g),
             @"B":@(b),
             @"A":@(a)};
}

-(IBAction)save:(id)sender
{
    NSString *etype = [SQLManager getEType:[self.deviceid intValue]];
    
    if ([sender isEqual:self.detailCell.power]) {
        NSData *data=[[DeviceInfo defaultManager] toogleLight:self.detailCell.power.isOn deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        BOOL isOn = self.detailCell.power.isOn;
        
        if (isOn) {
            self.detailCell.bright.value = 1;
        } else {
            self.detailCell.bright.value = 0;
        }
        
        self.detailCell.valueLabel.text = [NSString stringWithFormat:@"%d%%", (int)(self.detailCell.bright.value * 100)];
    }
    if (![etype isEqualToString:@"01"] && [sender isEqual:self.detailCell.bright]) {
        self.detailCell.power.on = self.detailCell.bright.value >0;
        
        NSData *data=[[DeviceInfo defaultManager] changeBright:self.detailCell.bright.value*100 deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
    }
    
    if ([etype isEqualToString:@"03"] && [sender isEqual:self.cell.colourView]) {
        UIColor *color = self.cell.colourView.backgroundColor;
        NSDictionary *colorDic = [self getRGBDictionaryByColor:color];
        int r = [colorDic[@"R"] floatValue] * 255;
        int g = [colorDic[@"G"] floatValue] * 255;
        int b = [colorDic[@"B"] floatValue] * 255;

        NSData *data=[[DeviceInfo defaultManager] changeColor:self.deviceid R:r G:g B:b];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:3];
    }
    
    Light *device=[[Light alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setIsPoweron: self.detailCell.power.isOn];
    NSArray *colors=[self changeUIColorToRGB:self.cell.colourView.backgroundColor];
    if (colors) {
        if ([etype isEqualToString:@"03"]) {
            [device setColor:colors];  
        }
        [device setColor:@[]];
    }
    
    if (![etype isEqualToString:@"01"])
    {
        [device setBrightness:self.detailCell.bright.value*100];
    }
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
}
#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    //同步设备状态
    if(proto.cmd == 0x01 && proto.action.state == 0x7D){
        self.detailCell.power.on = proto.action.RValue;
    }
    if (tag == 0 && (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON || proto.action.state == 0x0b || proto.action.state == 0x0a)) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
            //创建一个消息对象
            NSNotification * notice = [NSNotification notificationWithName:@"light" object:nil userInfo:@{@"state":@(proto.action.state),@"r":@(proto.action.RValue),@"g":@(proto.action.G),@"b":@(proto.action.B)}];
            //发送消息
            [[NSNotificationCenter defaultCenter] postNotification:notice];
        }
    }
}

//将UIColor转换为RGB值
- (NSArray *) changeUIColorToRGB:(UIColor *)color
{
    NSMutableArray *RGBStrValueArr = [[NSMutableArray alloc] init];
    NSString *RGBStr = nil;
    //获得RGB值描述
    NSString *RGBValue = [NSString stringWithFormat:@"%@",color];
    //将RGB值描述分隔成字符串
    NSArray *RGBArr = [RGBValue componentsSeparatedByString:@" "];
    //获取红色值
    int r = [[NSString stringWithFormat:@"%@",[RGBArr objectAtIndex:1]] floatValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",r];
    [RGBStrValueArr addObject:RGBStr];
    //获取绿色值
    int g = [[NSString stringWithFormat:@"%@",[RGBArr objectAtIndex:2] ] floatValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",g];
    [RGBStrValueArr addObject:RGBStr];
    //获取蓝色值
    int b = [[NSString stringWithFormat:@"%@",[RGBArr objectAtIndex:3]] floatValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",b];
    [RGBStrValueArr addObject:RGBStr];
    //返回保存RGB值的数组
    return RGBStrValueArr;
}

-(IBAction)changeColor:(id)sender
{
    HRSampleColorPickerViewController *controller= [[HRSampleColorPickerViewController alloc] initWithColor:self.cell.backgroundColor fullColor:NO indexPathRow:0];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)setSelectedColor:(UIColor *)color
{
    self.cell.colourView.backgroundColor = color;
    [self save:nil];
}


/*
#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *typeName = [SQLManager lightTypeNameByDeviceID:[self.deviceid intValue]];
    if ([typeName isEqualToString:@"调色灯"]) {
        return 3;
    }else{
        return 2;
    }
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *typeName = [SQLManager lightTypeNameByDeviceID:[self.deviceid intValue]];
    
    if(indexPath.row == 0)
    {
        self.detailCell.label.text = self.lNames[self.segmentLight.selectedSegmentIndex];
        
        if ([typeName isEqualToString:@"开关灯"] || [typeName isEqualToString:@"调色灯"]) {
            self.detailCell.bright.hidden = YES;
            self.detailCell.lightImg.hidden = YES;
            self.detailCell.brightImg.hidden = YES;
            self.detailCell.power.hidden = NO;
            self.detailCell.valueLabel.hidden = YES;
        } else if ([typeName isEqualToString:@"调光灯"]) {
            self.detailCell.bright.hidden = NO;
            self.detailCell.lightImg.hidden = NO;
            self.detailCell.brightImg.hidden = NO;
            self.detailCell.power.hidden = NO;
            self.detailCell.valueLabel.hidden = NO;
        }
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            self.detailCell.valueLabel.hidden = YES;
        }
        
        self.detailCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return self.detailCell;
    }
    
    if (indexPath.row == 1 && [typeName isEqualToString:@"调色灯"]) {
        self.cell.lable.text = @"自定义颜色";
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeColor:)];
        self.cell.colourView.userInteractionEnabled=YES;
        [self.cell.colourView addGestureRecognizer:singleTap];
        self.cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return self.cell;
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 100, 30)];
    [cell.contentView addSubview:label];
    label.text = @"详细信息";
    
    return cell;
    
}

//设置cell行高

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *typeName = [SQLManager lightTypeNameByDeviceID:[self.deviceid intValue]];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1)
    {
        if([typeName isEqualToString:@"调色灯"])
            return;
        [self performSegueWithIdentifier:@"detail" sender:self];
    }
    if(indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"detail" sender:self];
    }
}
*/
- (IBAction)selectTypeOfLight:(UISegmentedControl *)sender {
    
    self.detailCell.label.text = self.lNames[sender.selectedSegmentIndex];
    self.deviceid = [self.lIDs objectAtIndex:self.segmentLight.selectedSegmentIndex];
    [self syncUI];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

//明快
- (IBAction)SprightlierBtn:(id)sender {
    
    [[SceneManager defaultManager] sprightly:[self.sceneid intValue]];
}
//幽静
- (IBAction)PeacefulBtn:(id)sender {
    
    [[SceneManager defaultManager] gloom:[self.sceneid intValue]];
}
//浪漫
- (IBAction)RomanceBtn:(id)sender {
    
    [[SceneManager defaultManager] romantic:[self.sceneid intValue]];
}
- (IBAction)LightSlider:(id)sender {
    
    [[SceneManager defaultManager] dimingScene:[self.sceneid intValue] brightness:[self.deviceid intValue]];
    [self.lightSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"light" object:nil];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    
    NSUInteger toucheNum = [[event allTouches] count];//有几个手指触摸屏幕
    if ( toucheNum > 1 ) {
        return;//多个手指不执行旋转
    }
    
    CGFloat radius = atan2f(self.tranformView.transform.b, self.tranformView.transform.a);
    CGFloat degree = radius * (180 / M_PI);
    
    /**
     CGRectGetHeight 返回控件本身的高度
     CGRectGetMinY 返回控件顶部的坐标
     CGRectGetMaxY 返回控件底部的坐标
     CGRectGetMinX 返回控件左边的坐标
     CGRectGetMaxX 返回控件右边的坐标
     CGRectGetMidX 表示得到一个frame中心点的X坐标
     CGRectGetMidY 表示得到一个frame中心点的Y坐标
     */
    
    CGPoint center = CGPointMake(CGRectGetMidX([touch.view bounds]), CGRectGetMidY([touch.view bounds]));
    CGPoint currentPoint = [touch locationInView:touch.view];//当前手指的坐标
    CGPoint previousPoint = [touch previousLocationInView:touch.view];//上一个坐标
    
    /**
     求得每次手指移动变化的角度
     atan2f 是求反正切函数 参考:http://blog.csdn.net/chinabinlang/article/details/6802686
     */
    CGFloat angle = atan2f(currentPoint.y - center.y, currentPoint.x - center.x) - atan2f(previousPoint.y - center.y, previousPoint.x - center.x);
    
    if (degree<0) {
        if (angle<0) {
            return;
        }
    }else if (degree>135) {
        if (angle>0) {
            return;
        }
    }
    self.tranformView.transform = CGAffineTransformRotate(self.tranformView.transform, angle);
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGFloat radius = atan2f(self.tranformView.transform.b, self.tranformView.transform.a);
    CGFloat degree = radius * (180 / M_PI);
    NSLog(@"degree:%f",degree);
    int percent = degree*100/135;
}

-(void) initSwitch
{
    UIView *colorpad = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
    colorpad.center = CGPointMake(self.view.bounds.size.width / 2,
                                  self.view.bounds.size.height / 2);
    colorpad.backgroundColor = [UIColor blueColor];
    colorpad.layer.cornerRadius = colorpad.frame.size.width/2;
    //[self.view addSubview:colorpad];
    
    self.tranformView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240, 240)];
    self.tranformView.center = CGPointMake(self.view.bounds.size.width / 2,
                                  self.view.bounds.size.height / 2);
    self.tranformView.image = [UIImage imageNamed:@"glory"];
    
    
    ORBSwitch *switcher = [[ORBSwitch alloc] initWithCustomKnobImage:[UIImage imageNamed:@"lighting_off"] inactiveBackgroundImage:nil activeBackgroundImage:nil frame:CGRectMake(0, 0, 194, 194)];
    switcher.center = CGPointMake(self.view.bounds.size.width / 2,
                                  self.view.bounds.size.height / 2);
    switcher.knobRelativeHeight = 1.0f;
    switcher.delegate = self;
    [self.view addSubview:switcher];
    
    [self.view addSubview:self.tranformView];
}

#pragma mark - ORBSwitchDelegate
- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue {
    NSLog(@"Switch toggled: new state is %@", (newValue) ? @"ON" : @"OFF");
}

- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj {
    [switchObj setCustomKnobImage:[UIImage imageNamed:(switchObj.isOn) ? @"lighting_on" : @"lighting_off"]
          inactiveBackgroundImage:nil
            activeBackgroundImage:nil];

}

- (IBAction)loadCatalog:(id)sender {
    [self initiateMenuOptions];
    // init YALContextMenuTableView tableView
    if (!self.contextMenuTableView) {
        self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.animationDuration = 0.15;
        //optional - implement custom YALContextMenuTableView custom protocol
        self.contextMenuTableView.yalDelegate = self;
        //optional - implement menu items layout
        self.contextMenuTableView.menuItemsSide = Left;
        self.contextMenuTableView.menuItemsAppearanceDirection = FromTopToBottom;
        
        //register nib
        UINib *cellNib = [UINib nibWithNibName:@"ContextMenuCell" bundle:nil];
        [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
    }
    
    // it is better to use this method only for proper animation
    [self.contextMenuTableView showInView:self.view withEdgeInsets:UIEdgeInsetsMake(80+22,0,0,0) animated:YES];
}

#pragma mark - Local methods
- (void)initiateMenuOptions {
    self.menuTitles = @[@"床头射灯",
                        @"床尾射灯",
                        @"柜子射灯",
                        @"窗边射灯"];
}

#pragma mark - YALContextMenuTableViewDelegate
- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Menu dismissed with indexpath = %@", indexPath);
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView dismisWithIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 39;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuTitles.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
    
    if (cell) {
        cell.backgroundColor = [UIColor clearColor];
        cell.menuTitleLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
    }
    
    return cell;
}

@end
