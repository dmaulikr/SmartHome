//
//  IphoneLightController.m
//  SmartHome
//
//  Created by zhaona on 2016/11/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneLightController.h"
#import "Scene.h"
#import "SQLManager.h"
#import "Room.h"
#import "LightCell.h"
#import "Device.h"
#import "SceneManager.h"
#import "SocketManager.h"
#import "PackManager.h"
#import "CurtainTableViewCell.h"
#import "IphoneAirCell.h"

@interface IphoneLightController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet CurtainTableViewCell *cell;
@property (nonatomic,strong) NSArray * roomArrs;
@property (nonatomic,strong) NSArray * lightArrs;
@property (nonatomic,strong) NSArray * curtainArrs;
@property (nonatomic,strong) NSString * deviceid;
@property (nonatomic,strong) NSArray * airArrs;
@property (strong, nonatomic) Scene *scene;

@end

@implementation IphoneLightController
-(NSArray *)airArrs
{
    if (!_airArrs) {
        _airArrs = [NSArray array];
    }
    
    return _airArrs;
}
-(NSArray *)curtainArrs
{
    if (!_curtainArrs) {
        _curtainArrs = [NSArray array];
    }

    return _curtainArrs;
}
-(NSArray *)lightArrs
{
    if (!_lightArrs) {
        _lightArrs = [NSArray array];
    }

    return _lightArrs;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = view;
    _lightArrs   = [SQLManager getDeviceByRoom:self.roomID];
    _curtainArrs = [SQLManager getCurtainByRoom:self.roomID];
    _airArrs     = [SQLManager getAirDeviceByRoom:self.roomID];
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    [self.tableView registerNib:[UINib nibWithNibName:@"CurtainTableViewCell" bundle:nil] forCellReuseIdentifier:@"CurtainTableViewCell"];

    self.title = [SQLManager getRoomNameByRoomID:self.roomID];
}
-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.cell.slider]) {
        NSData *data=[[DeviceInfo defaultManager] roll:self.cell.slider.value * 100 deviceID:self.cell.deviceId];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
    }if ([sender isEqual:self.cell.open]) {
        self.cell.slider.value=1;
        NSData *data=[[DeviceInfo defaultManager] open:self.cell.deviceId];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
        self.cell.valueLabel.text = @"100%";
        
    }if ([sender isEqual:self.cell.close]) {
        self.cell.slider.value=0;
        NSData *data=[[DeviceInfo defaultManager] close:self.cell.deviceId];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
        self.cell.valueLabel.text = @"0%";
    }
    Curtain *device=[[Curtain alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setOpenvalue:self.cell.slider.value * 100];
    
    if ([sender isEqual:self.cell.open]) {
        [device setOpenvalue:100];
    }
    
    if ([sender isEqual:self.cell.close]) {
        [device setOpenvalue:0];
    }
    

}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (section==0) {
        return _lightArrs.count;
//    }else if (section == 1){
//        return _curtainArrs.count;
//    }

//    return _airArrs.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section == 0) {
        LightCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        Device *device = [SQLManager getDeviceWithDeviceID:[_lightArrs[indexPath.row] intValue]];
        cell.LightNameLabel.text = device.name;
        cell.slider.continuous = NO;
        cell.deviceid = self.lightArrs[indexPath.row];
    
//        return cell;

//    }else if (indexPath.section == 1){
//        CurtainTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CurtainTableViewCell" forIndexPath:indexPath];
//        Device * device = [SQLManager getDeviceWithDeviceID:[_curtainArrs[indexPath.row] intValue]];
//        cell.label.text = device.name;
//        cell.deviceId = _curtainArrs[indexPath.row];
//        
//        return cell;
//    }
//    IphoneAirCell * cell = [tableView dequeueReusableCellWithIdentifier:@"IphoneAirCell" forIndexPath:indexPath];
//      Device *device = [SQLManager getDeviceWithDeviceID:[_airArrs[indexPath.row] intValue]];
//    cell.deviceNameLabel.text = device.name;
//    cell.deviceId = _airArrs[indexPath.row];

    return cell;
}


#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 76;

    
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

@end
