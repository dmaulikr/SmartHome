//
//  RoomListController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/30.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#define backGroudColour [UIColor colorWithRed:55/255.0 green:73/255.0 blue:91/255.0 alpha:1]

#import "RoomListController.h"
#import "AddSenseCell.h"
#import "FixTimeRepeatController.h"
#import "RoomManager.h"
#import "Room.h"
#import <CoreLocation/CoreLocation.h>
#import "SunCount.h"
#import "Scene.h"
#import "SceneManager.h"
@interface RoomListController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,CLLocationManagerDelegate>
@property (nonatomic,strong) NSArray *rooms;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIButton *repeatBtn;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *hours;
@property (nonatomic,strong) NSArray *minutes;
@property (nonatomic,assign) BOOL isForenoon;
@property (nonatomic,strong) NSArray *noon;
@property (nonatomic,strong) FixTimeRepeatController *fixTimeVC;
//@property (nonatomic,strong) NSMutableArray *weeks;
@property (nonatomic,strong) NSMutableDictionary *weeks;


@property (weak, nonatomic) IBOutlet UIButton *startTimeBtn;

@property (weak, nonatomic) IBOutlet UIButton *endTimeBtn;
@property (weak, nonatomic) IBOutlet UIView *pickTimeView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerTime;
@property (strong,nonatomic) CLLocationManager *lm;

@property (nonatomic,strong) NSArray *antronomicalTimes;
@property (nonatomic,strong) Scene *scene;

@property (nonatomic,assign) int selectedRoomId;

@end

@implementation RoomListController


-(NSArray *)hours
{
    if(!_hours)
    {
        NSMutableArray *arr = [NSMutableArray array];
        for(int i = 0; i< 24; i++)
        {
            if(i < 10){
                [arr addObject:[NSString stringWithFormat:@"0%d",i]];
            }else{
                [arr addObject:[NSString stringWithFormat:@"%d",i]];
            }
            
        }
        _hours = [arr copy];
    }
    return _hours;
}
-(NSArray *)minutes
{
    if(!_minutes)
    {
        NSMutableArray *arr = [NSMutableArray array];
        for(int i = 0; i< 60; i++)
        {
            if(i < 10){
                [arr addObject:[NSString stringWithFormat:@"0%d",i]];
            }else{
                [arr addObject:[NSString stringWithFormat:@"%d",i]];
            }

        }
        _minutes = [arr copy];

    }
    return _minutes;
}
-(NSArray *)noon{
    if(!_noon)
    {
        _noon = @[@"AM",@"PM"];
    }
    return _noon;
}
-(FixTimeRepeatController *)fixTimeVC
{
    if(!_fixTimeVC)
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        _fixTimeVC = [story instantiateViewControllerWithIdentifier:@"FixTimeRepeatController"];
    }
    return _fixTimeVC;
}
-(NSMutableDictionary *)weeks
{
    if(!_weeks)
    {
        _weeks = [NSMutableDictionary dictionary];
    }
    return _weeks;
}
-(NSArray *)rooms
{
    if(!_rooms)
    {
        _rooms = [RoomManager getAllRoomsInfo];
    }
    return _rooms;
}
-(Scene *)scene
{
    if(!_scene)
    {
        _scene = [[Scene alloc] initWhithoutSchedule];
    }
    return _scene;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.timeView.layer.cornerRadius = 10;
    self.timeView.layer.masksToBounds = YES;
    

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = [UIView new];
   
    if ([CLLocationManager locationServicesEnabled]) {
        self.lm = [[CLLocationManager alloc]init];
        self.lm.delegate = self;
        // 最小距离
        self.lm.distanceFilter=kCLDistanceFilterNone;
    }else{
        NSLog(@"定位服务不可利用");
    }


    [self.tableView selectRowAtIndexPath:0 animated:YES scrollPosition:UITableViewScrollPositionTop];
    self.splitViewController.maximumPrimaryColumnWidth = 250;
    self.tableView.backgroundColor = backGroudColour;
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectWeek:) name:@"SelectWeek" object:nil];

   }
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //默认选中第一行
    NSIndexPath *selectedIndexPath  = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    if([self.delegate respondsToSelector:@selector(RoomListControllerDelegate:SelectedRoom:)])
    {
        Room *room = self.rooms[0];
        [self.delegate RoomListControllerDelegate:self SelectedRoom:room.rId];
    }
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.rooms.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddSenseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"roomListCell" forIndexPath:indexPath];
   

    Room *room = self.rooms[indexPath.row];
    cell.roomName.text = room.rName;
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    cell.backgroundColor = backGroudColour;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //当点击某一行时，通过房间ID获得所有的设备
   if([self.delegate respondsToSelector:@selector(RoomListControllerDelegate:SelectedRoom:)])
    {
        Room *room = self.rooms[indexPath.row];
        [self.delegate RoomListControllerDelegate:self SelectedRoom:room.rId];
       // self.selectedRoomId = room.rId;
    }
    
}


#pragma  mark - UIPickerViewDelegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
    {
        return self.hours.count;
    }else if(component == 1)
    {
        return self.minutes.count;
    }else {
        return 2;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0 )
    {
        return self.hours[row];
    }else if(component == 1){
        return self.minutes[row];
    }else {
        return self.noon[row];
    }
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 0)
    {
        int hour = [self.hours[row] intValue];
        if(hour <12 || hour == 12)
        {
            [pickerView selectRow:0 inComponent:2 animated:YES];
        }else {
            [pickerView selectRow:1 inComponent:2 animated:YES];

        }
        
    }
    
    NSString *hour = self.hours[[self.pickerTime selectedRowInComponent:0]];
    NSString *min = self.minutes[[self.pickerTime selectedRowInComponent:1]];
    NSString *noon = self.noon[[self.pickerTime selectedRowInComponent:2]];
    NSString *time = [NSString stringWithFormat:@"%@:%@ %@", hour, min, noon];
    
    
    if (self.startTimeBtn.selected) {
        [self.startTimeBtn setTitle:time forState:UIControlStateNormal];
    } else {
        [self.endTimeBtn setTitle:time forState:UIControlStateNormal];
    }
    
    [self save];
    
}


- (IBAction)settingRepeatTime:(UIButton *)sender {
    self.fixTimeVC.modalPresentationStyle = UIModalPresentationPopover;
    self.fixTimeVC.popoverPresentationController.sourceView = sender;
    self.fixTimeVC.popoverPresentationController.sourceRect = sender.bounds;
   
    self.fixTimeVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionLeft;
    [self presentViewController:self.fixTimeVC animated:YES completion:nil];
}
- (void)selectWeek:(NSNotification *)noti
{
    NSDictionary *dict = noti.userInfo;
    NSString *strWeek = dict[@"week"];
    NSString *strSelect = dict[@"select"];
    
    self.weeks[strWeek] = strSelect;
    
    int week[ 7 ] = {0};
    
    for (NSString *key in [self.weeks allKeys]) {
        int index = [key intValue];
        int select = [self.weeks[key] intValue];
        
        week[index] = select;
    }
    
    NSMutableString *display = [NSMutableString string];
    
    if (week[1] == 0 && week[2] == 0 && week[3] == 0 && week[4] == 0 && week[5] == 0 && week[0] == 0 && week[6] == 0) {
        [display appendString:@"永不"];
    }
    else if (week[1] == 1 && week[2] == 1 && week[3] == 1 && week[4] == 1 && week[5] == 1 && week[0] == 1 && week[6] == 1) {
        [display appendString:@"每天"];
    }
    else if (week[1] == 1 && week[2] == 1 && week[3] == 1 && week[4] == 1 && week[5] == 1 && week[0] == 0 && week[6] == 0) {
        [display appendString:@"工作日"];
    }
    else if ( week[1] == 0 && week[2] == 0 && week[3] == 0 && week[4] == 0 && week[5] == 0 && week[0] == 1 && week[6] == 1 ) {
        [display appendString:@"周末"];
    }
    else {
        for (int i = 1; i < 7; i++) {
            if (week[i] == 1) {
                switch (i) {
                    case 1:
                        [display appendString:@"周一"];
                        break;
                        
                    case 2:
                        [display appendString:@"周二"];
                        break;
                        
                    case 3:
                        [display appendString:@"周三"];
                        break;
                        
                    case 4:
                        [display appendString:@"周四"];
                        break;
                        
                    case 5:
                        [display appendString:@"周五"];
                        break;
                        
                    case 6:
                        [display appendString:@"周六"];
                        break;
                        
                    default:
                        break;
                }
            }
        }
        if (week[0] == 1) {
            [display appendString:@"周日"];
        }
    }
    
    [self.repeatBtn setTitle:display forState:UIControlStateNormal];
    [self save];
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (IBAction)clickFixTimeBtn:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    if(btn.selected)
    {
        self.timeView.hidden = YES;
    }else {
        self.timeView.hidden =  NO;
        NSString  *astronomicealTime;
        NSDictionary *dic;
        int isPlane;
        int playType;
        if([self.startTimeBtn.titleLabel.text isEqualToString:@"设置"])
        {
            isPlane = 2;
            
        }else{
            if([self.startTimeBtn.titleLabel.text isEqualToString:@"黎明"]){
                astronomicealTime = @"1";
            }else if([self.startTimeBtn.titleLabel.text isEqualToString:@"日出"]){
                astronomicealTime = @"2";
            }else if([self.startTimeBtn.titleLabel.text isEqualToString:@"日落"]){
                astronomicealTime = @"3";
            }else {
                astronomicealTime = @"4";
            }
            
            if(astronomicealTime)
            {
                playType = 2;
            }else{
                playType = 1;
            }
            isPlane = 1;
            dic = @{@"astronomicealTime":astronomicealTime,@"playType":[NSNumber numberWithInt:playType],@"startTIme":self.startTimeBtn.titleLabel.text,@"eendTime":self.endTimeBtn.titleLabel.text,@"isPane":[NSNumber numberWithInt:isPlane]};
            
        }
      
       
        
    }
    btn.selected = !btn.selected;
}

- (IBAction)setTimeOnClick:(UIButton *)sender {
    
    if (sender == self.startTimeBtn)
    {
        if (self.startTimeBtn.selected)
        {
            self.startTimeBtn.selected = NO;
        }
        else {
            self.startTimeBtn.selected = YES;
            self.endTimeBtn.selected = NO;
        }
    }
    else {
        if (self.endTimeBtn.selected) {
            self.endTimeBtn.selected = NO;
        }
        else {
            self.startTimeBtn.selected = NO;
            self.endTimeBtn.selected = YES;
            
            
        }
    }
    
    if (self.startTimeBtn.selected || self.endTimeBtn.selected) {
        self.pickTimeView.hidden = NO;
        
    } else {
        self.pickTimeView.hidden = YES;
    }

}

- (void) save {
    int startType = 0;
    
    NSString *startTimeType = self.startTimeBtn.titleLabel.text;
    if ([startTimeType isEqualToString:@"设置"]) {
        startType = 0;
    } else if ([startTimeType isEqualToString:@"黎明"]) {
        startType = 1;
    } else if ([startTimeType isEqualToString:@"日出"]) {
        startType = 2;
    } else if ([startTimeType isEqualToString:@"日落"]) {
        startType = 3;
    } else if ([startTimeType isEqualToString:@"黄昏"]) {
        startType = 4;
    } else {
        startType = 5;
    }
    
    if (startType == 0) {
        return;
    }
    
//    int endType = 0;
//    
//    NSString *endTimeType = self.endTimeBtn.titleLabel.text;
//    if ([endTimeType isEqualToString:@"设置"]) {
//        endType = 0;
//    } else if ([endTimeType isEqualToString:@"黎明"]) {
//        endType = 1;
//    } else if ([endTimeType isEqualToString:@"日出"]) {
//        endType = 2;
//    } else if ([endTimeType isEqualToString:@"日落"]) {
//        endType = 3;
//    } else if ([endTimeType isEqualToString:@"黄昏"]) {
//        endType = 4;
//    } else {
//        endType = 5;
//    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    param[@"IsPlan"] = @"1";
    if (startType == 5) {
        NSDate *senddate = [NSDate date];
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YYYY-MM-dd"];
        NSString *locationString = [dateformatter stringFromDate:senddate];
        
        NSString *startTime = [NSString stringWithFormat:@"%@ %@", locationString, [self.startTimeBtn.titleLabel.text substringToIndex:5]];
        
        param[@"StartTime"] = startTime;
        param[@"PlanType"] = @1;
       
    } else {
        param[@"AstronomicalTime"] = [NSNumber numberWithInteger:startType];
        param[@"PlanType"] = @2;
    }
    
    int week[ 7 ] = {0};
    
    for (NSString *key in [self.weeks allKeys]) {
        int index = [key intValue];
        int select = [self.weeks[key] intValue];
        
        week[index] = select;
    }
    
    NSMutableString *weekValue = [NSMutableString string];
    
    BOOL isRepeat = false;
    
    for (int i = 0; i < 7; i++) {
        if (week[i]) {
            NSString *temp = [NSString stringWithFormat:@"%d", i];
            [weekValue appendString:temp];
            isRepeat = true;
        }
    }
    
    param[@"WeekValue"] = weekValue;
    
    Scene *scene=[[Scene alloc] initWhithoutSchedule];
    [scene setWeekValue:param[@"WeekValue"]];
    [scene setPlanType:[param[@"PlanType"] intValue]];
   // [scene setIsPlan:[param[@"isPlan"] intValue]];
    
    if (scene.planType == 1) {
        
        [scene setStartTime:param[@"StartTime"]];
    } else {
    
        [scene setAstronomicalTime:param[@"AstronomicalTime"]];
    }
    [scene setWeekRepeat:isRepeat];
    
    [scene setDevices:@[]];
    
    [scene setReadonly:NO];
    
    [[SceneManager defaultManager] addScene:scene withName:nil withPic:@""];
}





- (IBAction)setAstromomicalTime:(id)sender {
    
    if (self.lm!=nil) {
        [self.lm startUpdatingLocation];
    }
    UIButton *btn = (UIButton *)sender;
    if(btn.tag == 0)
    {
        [self.startTimeBtn setTitle:@"黎明" forState:UIControlStateNormal];
        
        
    }else if(btn.tag == 1)
    {
        [self.startTimeBtn setTitle:@"日出" forState:UIControlStateNormal];
        
    }else if(btn.tag == 2)
    {
        [self.startTimeBtn setTitle:@"日落" forState:UIControlStateNormal];
        
    }else{
        [self.startTimeBtn setTitle:@"黄昏" forState:UIControlStateNormal];
    }
    [self save];

}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    [SunCount sunrisetWithLongitude:newLocation.coordinate.longitude andLatitude:newLocation.coordinate.latitude
                        andResponse:^(SunString *str){
                            NSLog(@"%@,%@,%@,%@",str.dayspring, str.sunrise,str.sunset,str.dusk);
                            self.antronomicalTimes = @[str.dayspring,str.sunrise,str.sunset,str.dusk];
                        }];
}

- (IBAction)gotoLastViewController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
