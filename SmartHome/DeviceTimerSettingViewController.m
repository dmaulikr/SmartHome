//
//  DeviceTimerSettingViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/5/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "DeviceTimerSettingViewController.h"

@interface DeviceTimerSettingViewController ()

@end

@implementation DeviceTimerSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifications];
    [self initUI];
}

- (void)setupNaviBar {
    [self setNaviBarTitle:@"定时设置"]; //设置标题
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
    [self setNaviBarRightBtn:_naviRightBtn];
}

- (void)rightBtnClicked:(UIButton *)btn {
    [self addDeviceTimer];
}

- (void)addDeviceTimer {
    
    if (_startTime.length <=0 || _endTime.length <=0) {
        [MBProgressHUD showError:@"请选择时段"];
        return;
    }
    
    if (_repeatition.length <= 0) {
        [MBProgressHUD showError:@"请选择重复选项"];
        return;
    }
    
    if (_switchBtnString.length <= 0 ) {
        _switchBtnString = @"01000000";
    }
    
    if (_sliderBtnString.length <= 0) {
        _sliderBtnString =  @"2AFF0000";
    }
    
    _startValue = [NSMutableString string];
    [_startValue appendString:_switchBtnString];
    [_startValue appendString:@","];
    [_startValue appendString:_sliderBtnString];
    
    NSString *url = [NSString stringWithFormat:@"%@Cloud/eq_timing.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    
    if (auothorToken.length >0) {
        NSDictionary *dict = @{@"token":auothorToken,
                               @"optype":@(1),
                               @"isactive":@(_isActive),
                               @"starttime":_startTime,
                               @"endtime":_endTime,
                               @"weekvalue":_repeatString,
                               @"equipmentid":@(_device.eID),
                               @"startvalue":_startValue
                               };
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dict];
    }
}

#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1) {
        
        if ([responseObject[@"result"] intValue] == 0) {
            [MBProgressHUD showSuccess:@"添加成功"];
            [self.navigationController popViewControllerAnimated:YES];
            //[self.navigationController popToViewController:vc animated:YES];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else {
            [MBProgressHUD showSuccess:@"添加失败"];
        }
    }
}

- (void)initUI {
    [self setupNaviBar];
    _isActive = 1;
    _startValue = [NSMutableString string];
    [_startValue appendString:@"01000000"];//默认开
    
    _timerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    _timerTableView.dataSource = self;
    _timerTableView.delegate = self;
    _timerTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    _timerTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _timerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [self.timerTableView registerNib:[UINib nibWithNibName:@"NewLightCell" bundle:nil] forCellReuseIdentifier:@"NewLightCell"];//灯光
    [self.timerTableView registerNib:[UINib nibWithNibName:@"NewColourCell" bundle:nil] forCellReuseIdentifier:@"NewColourCell"];//调色灯
    [self.timerTableView registerNib:[UINib nibWithNibName:@"AireTableViewCell" bundle:nil] forCellReuseIdentifier:@"AireTableViewCell"];//空调
    [self.timerTableView registerNib:[UINib nibWithNibName:@"CurtainTableViewCell" bundle:nil] forCellReuseIdentifier:@"CurtainTableViewCell"];//窗帘
    [self.timerTableView registerNib:[UINib nibWithNibName:@"TVTableViewCell" bundle:nil] forCellReuseIdentifier:@"TVTableViewCell"];//网络电视
    [self.timerTableView registerNib:[UINib nibWithNibName:@"OtherTableViewCell" bundle:nil] forCellReuseIdentifier:@"OtherTableViewCell"];//其他
    [self.timerTableView registerNib:[UINib nibWithNibName:@"ScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScreenTableViewCell"];//投影仪ScreenTableViewCell
    [self.timerTableView registerNib:[UINib nibWithNibName:@"ScreenCurtainCell" bundle:nil] forCellReuseIdentifier:@"ScreenCurtainCell"];//幕布ScreenCurtainCell
    [self.timerTableView registerNib:[UINib nibWithNibName:@"DVDTableViewCell" bundle:nil] forCellReuseIdentifier:@"DVDTableViewCell"];//DVD
    [self.timerTableView registerNib:[UINib nibWithNibName:@"BjMusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"BjMusicTableViewCell"];//背景音乐
    [self.timerTableView registerNib:[UINib nibWithNibName:@"FMTableViewCell" bundle:nil] forCellReuseIdentifier:@"FMTableViewCell"];//FM收音机
    
    [self.view addSubview:_timerTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 2) {
        return 0.5f;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.5)];
    header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_line"]];
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 2) {
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.5)];
        footer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_line"]];
        
        return footer;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.device.hTypeId == 11 || self.device.hTypeId == 12 || self.device.hTypeId == 13 || self.device.hTypeId == 15) {
            return 150.0f;
        }else if (self.device.hTypeId == 16 || self.device.hTypeId == 18 || self.device.subTypeId == 5) {
            return 50.0f;
        }else if (self.device.hTypeId == 1) { //开关灯cell
            return 70.0f;
        }
        else {
            return 100.0f;
        }
    }
    
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.device.subTypeId == 1) { //灯光
            if (self.device.hTypeId == 1) { //调光灯
                NewColourCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewColourCell" forIndexPath:indexPath];
                cell.delegate = self;
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.AddColourLightBtn.hidden = YES;
                cell.ColourLightConstraint.constant = 10;
                cell.colourNameLabel.text = self.device.name;
                cell.colourSlider.continuous = NO;
                cell.colourSlider.hidden = YES;
                cell.supimageView.hidden = YES;
                cell.lowImageView.hidden = YES;
                cell.highImageView.hidden = YES;
                cell.deviceid = [NSString stringWithFormat:@"%d", self.device.eID];
                return cell;
            }else if (self.device.hTypeId == 2) { //调光灯
                NewLightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewLightCell" forIndexPath:indexPath];
                cell.delegate = self;
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.AddLightBtn.hidden = YES;
                cell.LightConstraint.constant = 10;
                cell.NewLightNameLabel.text = self.device.name;
                cell.NewLightSlider.continuous = NO;
                cell.deviceid = [NSString stringWithFormat:@"%d", self.device.eID];
                return cell;
                
            }else if (self.device.hTypeId == 3) {  //调色灯
                NewColourCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewColourCell" forIndexPath:indexPath];
                cell.delegate = self;
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.AddColourLightBtn.hidden = YES;
                cell.ColourLightConstraint.constant = 10;
                cell.colourNameLabel.text = self.device.name;
                cell.colourSlider.continuous = NO;
                cell.colourSlider.hidden = YES;
                cell.supimageView.hidden = YES;
                cell.lowImageView.hidden = YES;
                cell.highImageView.hidden = YES;
                cell.deviceid = [NSString stringWithFormat:@"%d", self.device.eID];
                return cell;
            }
            
        }else if (self.device.subTypeId == 7) { //窗帘
            CurtainTableViewCell *curtainCell = [tableView dequeueReusableCellWithIdentifier:@"CurtainTableViewCell" forIndexPath:indexPath];
            curtainCell.delegate = self;
            curtainCell.backgroundColor =[UIColor clearColor];
            curtainCell.selectionStyle = UITableViewCellSelectionStyleNone;
            curtainCell.AddcurtainBtn.hidden = YES;
            curtainCell.curtainContraint.constant = 10;
            curtainCell.roomID = (int)self.roomID;
            curtainCell.label.text = self.device.name;
            curtainCell.deviceid = [NSString stringWithFormat:@"%d", self.device.eID];
            
            return curtainCell;
        }else if (self.device.hTypeId == 31) {  //空调
            AireTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"AireTableViewCell" forIndexPath:indexPath];
            aireCell.delegate = self;
            aireCell.backgroundColor = [UIColor clearColor];
            aireCell.selectionStyle = UITableViewCellSelectionStyleNone;
            aireCell.AddAireBtn.hidden = YES;
            aireCell.AireConstraint.constant = 10;
            aireCell.roomID = (int)self.roomID;
            aireCell.AireNameLabel.text = self.device.name;
            aireCell.deviceid = [NSString stringWithFormat:@"%d", self.device.eID];
            return aireCell;
        }else if (self.device.hTypeId == 14) { //背景音乐
            BjMusicTableViewCell * BjMusicCell = [tableView dequeueReusableCellWithIdentifier:@"BjMusicTableViewCell" forIndexPath:indexPath];
            BjMusicCell.delegate = self;
            BjMusicCell.backgroundColor = [UIColor clearColor];
            BjMusicCell.selectionStyle = UITableViewCellSelectionStyleNone;
            BjMusicCell.AddBjmusicBtn.hidden = YES;
            BjMusicCell.BJmusicConstraint.constant = 10;
            BjMusicCell.BjMusicNameLb.text = self.device.name;
            return BjMusicCell;
        }else if (self.device.hTypeId == 13) { //DVD
            DVDTableViewCell * dvdCell = [tableView dequeueReusableCellWithIdentifier:@"DVDTableViewCell" forIndexPath:indexPath];
            dvdCell.delegate = self;
            dvdCell.backgroundColor =[UIColor clearColor];
            dvdCell.selectionStyle = UITableViewCellSelectionStyleNone;
            dvdCell.AddDvdBtn.hidden = YES;
            dvdCell.DVDConstraint.constant = 10;
            dvdCell.DVDNameLabel.text = self.device.name;
            return dvdCell;
        }else if (self.device.hTypeId == 15) { //FM收音机
            FMTableViewCell * FMCell = [tableView dequeueReusableCellWithIdentifier:@"FMTableViewCell" forIndexPath:indexPath];
            FMCell.delegate = self;
            FMCell.backgroundColor =[UIColor clearColor];
            FMCell.selectionStyle = UITableViewCellSelectionStyleNone;
            FMCell.AddFmBtn.hidden = YES;
            FMCell.FMLayouConstraint.constant = 10;
            FMCell.FMNameLabel.text = self.device.name;
            return FMCell;
        }else if (self.device.hTypeId == 17) { //幕布
            ScreenCurtainCell * ScreenCell = [tableView dequeueReusableCellWithIdentifier:@"ScreenCurtainCell" forIndexPath:indexPath];
            ScreenCell.delegate = self;
            ScreenCell.backgroundColor =[UIColor clearColor];
            ScreenCell.selectionStyle = UITableViewCellSelectionStyleNone;
            ScreenCell.AddScreenCurtainBtn.hidden = YES;
            ScreenCell.ScreenCurtainConstraint.constant = 10;
            ScreenCell.ScreenCurtainLabel.text = self.device.name;
            return ScreenCell;
        }else if (self.device.hTypeId == 16) { //投影仪(只有开关)
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.delegate = self;
            otherCell.backgroundColor = [UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = self.device.name;
            return otherCell;
        }else if (self.device.hTypeId == 11) { //电视（以前叫机顶盒）
            TVTableViewCell * tvCell = [tableView dequeueReusableCellWithIdentifier:@"TVTableViewCell" forIndexPath:indexPath];
            tvCell.delegate = self;
            tvCell.backgroundColor =[UIColor clearColor];
            tvCell.selectionStyle = UITableViewCellSelectionStyleNone;
            tvCell.AddTvDeviceBtn.hidden = YES;
            tvCell.TVConstraint.constant = 10;
            tvCell.TVNameLabel.text = self.device.name;
            return tvCell;
        }/*else if (self.device.hTypeId == 12) { //网络电视
            TVTableViewCell * tvCell = [tableView dequeueReusableCellWithIdentifier:@"TVTableViewCell" forIndexPath:indexPath];
            tvCell.backgroundColor =[UIColor clearColor];
            tvCell.selectionStyle = UITableViewCellSelectionStyleNone;
            tvCell.AddTvDeviceBtn.hidden = YES;
            tvCell.TVConstraint.constant = 10;
            tvCell.TVNameLabel.text = self.device.name;
            return tvCell;
        }*/else if (self.device.hTypeId == 18) { //功放
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.delegate = self;
            otherCell.backgroundColor =[UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = self.device.name;
            return otherCell;
        }else { //其他类型: 智能浇花，智能投食，推窗器
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.delegate = self;
            otherCell.backgroundColor =[UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = self.device.name;
            return otherCell;
        }
        
    }else if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"应用时段";
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.backgroundColor = [UIColor clearColor];
        
        //时间段 label
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 12, UI_SCREEN_WIDTH-160, 20)];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = NSTextAlignmentLeft;
        timeLabel.font = [UIFont systemFontOfSize:15];
        timeLabel.adjustsFontSizeToFitWidth = YES;
        if (_startTime.length >0 && _endTime.length >0 && _repeatition.length >0) {
            timeLabel.text = [NSString stringWithFormat:@"%@-%@, %@", _startTime, _endTime, _repeatition];
        }
        [cell.contentView addSubview:timeLabel];
        
        return cell;
    }else if (indexPath.section == 2) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"立即启动";
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIButton *activeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 23)];
        activeBtn.selected = _isActive;
        [activeBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
        [activeBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
        [activeBtn addTarget:self action:@selector(activeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = activeBtn;
        
        return cell;
    }
    
    return nil;
}

- (void)activeBtnClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
    _isActive = btn.selected;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (indexPath.section == 1) {
        UIStoryboard * sceneStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
        IphoneNewAddSceneTimerVC * timerVC = [sceneStoryBoard  instantiateViewControllerWithIdentifier:@"IphoneNewAddSceneTimerVC"];
        timerVC.naviTitle = @"设备定时";
        [self.navigationController pushViewController:timerVC animated:YES];
    }
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(deviceTimerNotification:) name:@"AddSceneOrDeviceTimerNotification" object:nil];
}

- (void)removeNotifications {
    [NC removeObserver:self];
}

- (void)deviceTimerNotification:(NSNotification *)noti {
    NSDictionary *dic = noti.userInfo;
    
    _startTime = dic[@"startDay"];
    _endTime = dic[@"endDay"];
    _repeatition = dic[@"repeat"];
    
    [_timerTableView reloadData];
    
    NSArray *weekArray = dic[@"weekArray"];
    _repeatString =  [NSMutableString string];
    if (weekArray && [weekArray isKindOfClass:[NSArray class]] && weekArray.count >0) {
        
        for (int i=0; i < 7; i++) {
            if ([weekArray[i] intValue] == 1) {
                [_repeatString appendString:[NSString stringWithFormat:@"%d", i]];
            }
        }
    }
    
}

- (void)dealloc {
    [self removeNotifications];
}


#pragma mark - NewLightCellDelegate
- (void)onLightPowerBtnClicked:(UIButton *)btn {
    
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

#pragma mark - ColorLightCellDelegate
- (void)onColourSwitchBtnClicked:(UIButton *)btn {
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

#pragma mark - CurtainCellDelegate
- (void)onCurtainOpenBtnClicked:(UIButton *)btn {
    
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

- (void)onCurtainSliderBtnValueChanged:(UISlider *)slider {
    
    NSString *hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%2x", (int)slider.value*100]];
    if (hexString.length == 2) {
        _sliderBtnString = [NSString stringWithFormat:@"2A%@0000", hexString];
    }else {
        _sliderBtnString = @"2AFF0000";//默认值
    }
}

#pragma mark - AirCellDelegate
- (void)onAirSwitchBtnClicked:(UIButton *)btn {
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

- (void)onAirSliderValueChanged:(UISlider *)slider {
    NSString *hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%2x", (int)lroundf(slider.value)]];
    if (hexString.length == 2) {
        _sliderBtnString = [NSString stringWithFormat:@"6A%@0000", hexString];
    }else {
        _sliderBtnString = @"6AFF0000";//默认值
    }
}

#pragma mark - TVTableViewCellDelegate
- (void)onTVSwitchBtnClicked:(UIButton *)btn {
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

- (void)onTVSliderValueChanged:(UISlider *)slider {
    NSString *hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%2x", (int)slider.value*100]];
    if (hexString.length == 2) {
        _sliderBtnString = [NSString stringWithFormat:@"AA%@0000", hexString];
    }else {
        _sliderBtnString = @"AAFF0000";//默认值 (电视音量)
    }
}

#pragma mark - DVDTableViewCellDelegate
- (void)onDVDSwitchBtnClicked:(UIButton *)btn {
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

- (void)onDVDSliderValueChanged:(UISlider *)slider {
    NSString *hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%2x", (int)slider.value*100]];
    if (hexString.length == 2) {
        _sliderBtnString = [NSString stringWithFormat:@"AA%@0000", hexString];
    }else {
        _sliderBtnString = @"AAFF0000";//默认值 (DVD音量)
    }
}

#pragma mark - BjMusicTableViewCellDelegate
- (void)onBjPowerButtonClicked:(UIButton *)btn {
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

- (void)onBjSliderValueChanged:(UISlider *)slider {
    NSString *hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%2x", (int)slider.value*100]];
    if (hexString.length == 2) {
        _sliderBtnString = [NSString stringWithFormat:@"AA%@0000", hexString];
    }else {
        _sliderBtnString = @"AAFF0000";//默认值 (背景音乐音量)
    }
}

#pragma mark - FMTableViewCellDelegate
- (void)onFMSwitchBtnClicked:(UIButton *)btn {
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

- (void)onFMSliderValueChanged:(UISlider *)slider {
    NSString *hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%2x", (int)slider.value*100]];
    if (hexString.length == 2) {
        _sliderBtnString = [NSString stringWithFormat:@"AA%@0000", hexString];
    }else {
        _sliderBtnString = @"AAFF0000";//默认值 (FM音量)
    }
}

- (void)onFMChannelSliderValueChanged:(UISlider *)slider {
    float frequence = 80+slider.value*40;// frequence取整后，作为高字节
    int dec = (int)((frequence - (int)frequence)*10);// 小数部分 作为低字节
    
    NSString *hexString_frequence = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%2x", (int)frequence]];
    NSString *hexString_dec = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%2x", dec]];
    if (hexString_frequence.length == 2 && hexString_dec.length == 2) {
        _FMChannelSliderString = [NSString stringWithFormat:@"3A%@%@00", hexString_frequence, hexString_dec];
    }else {
        _FMChannelSliderString = @"3AFFFF00";
    }
}

#pragma mark - ScreenCurtainCellDelegate
- (void)onUPBtnClicked:(UIButton *)btn {
    _switchBtnString = @"33000000"; //幕布--升
}

- (void)onDownBtnClicked:(UIButton *)btn {
    _switchBtnString = @"34000000"; //幕布--降
}

- (void)onStopBtnClicked:(UIButton *)btn {
    _switchBtnString = @"32000000"; //幕布--停
}

#pragma mark - OtherTableViewCellDelegate
- (void)onOtherSwitchBtnClicked:(UIButton *)btn {
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

@end