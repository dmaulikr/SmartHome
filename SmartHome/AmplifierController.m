
//
//  AmplifierController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/2.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "AmplifierController.h"
#import "DetailTableViewCell.h"
#import "SQLManager.h"
#import "SocketManager.h"
#import "Amplifier.h"
#import "SceneManager.h"
#import "PackManager.h"
#import "ORBSwitch.h"

@interface AmplifierController ()<UITableViewDelegate,UITableViewDataSource,ORBSwitchDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (nonatomic,strong) DetailTableViewCell *cell;
@property (nonatomic,strong) NSMutableArray *amplifierNames;
@property (nonatomic,strong) NSMutableArray *amplifierIDArr;
@property (nonatomic,strong) ORBSwitch *switcher;
@end

@implementation AmplifierController

-(NSMutableArray *)amplifierIDArr
{
    if(!_amplifierIDArr)
    {
        _amplifierIDArr = [NSMutableArray array];
        
        if(self.sceneid > 0 && !self.isAddDevice)
        {
            NSArray *amplifiers = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i<amplifiers.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[amplifiers[i] intValue]];
                if([typeName isEqualToString:@"功放"])
                {
                    [_amplifierIDArr addObject:amplifiers[i]];
                }

            }
        }else if(self.roomID)
        {
            [_amplifierIDArr addObject:[SQLManager singleDeviceWithCatalogID:amplifier byRoom:self.roomID]];
            
        }else{
            [_amplifierIDArr addObject:self.deviceid];
        }
        
    }
    return _amplifierIDArr;
}

-(NSMutableArray *)amplifierNames
{
    if(!_amplifierNames)
    {
        _amplifierNames = [NSMutableArray array];
        for(int i = 0; i < self.amplifierIDArr.count; i++)
        {
            int amplifierID = [self.amplifierIDArr[i] intValue];
            [_amplifierNames addObject:[SQLManager deviceNameByDeviceID:amplifierID]];
        }
    }
    return _amplifierNames;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNaviBarTitle:@"功放"];
    self.deviceid=[self.amplifierIDArr objectAtIndex:0];
    [self initSwitcher];
}

-(void) initSwitcher
{
    self.switcher = [[ORBSwitch alloc] initWithCustomKnobImage:[UIImage imageNamed:@"lighting_off"] inactiveBackgroundImage:nil activeBackgroundImage:nil frame:CGRectMake(0, 0, 194, 194)];
    self.switcher.center = CGPointMake(self.view.bounds.size.width / 2,
                                       self.view.bounds.size.height / 2);
    
    self.switcher.knobRelativeHeight = 1.0f;
    self.switcher.delegate = self;
    
    [self.view addSubview:self.switcher];
}

-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.switcher]) {
        NSData *data=[[DeviceInfo defaultManager] toogle:self.switcher.isOn deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    Amplifier *device=[[Amplifier alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setWaiting: self.switchView.isOn];
    
    
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
    
    if (tag==0 && (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON)) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
            self.switchView.on=proto.action.state;
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        self.cell = cell;
        //cell.label.text = self.amplifierNames[self.segment.selectedSegmentIndex];
        self.switchView = cell.power;//[[UISwitch alloc] initWithFrame:CGRectZero];
        _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        if ([self.sceneid intValue]>0) {
            for(int i=0;i<[_scene.devices count];i++)
            {
                if ([[_scene.devices objectAtIndex:i] isKindOfClass:[Amplifier class]]) {
                    cell.power.on=((Amplifier *)[_scene.devices objectAtIndex:i]).waiting;
                }
            }
        }
        [cell.power addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recell"];
        if(!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"recell"];
            
        }
        
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 100, 30)];
        [cell.contentView addSubview:label];
        label.text = @"详细信息";
        return cell;
    }
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 1)
    {
        [self performSegueWithIdentifier:@"detail" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ORBSwitchDelegate
- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue {
    NSLog(@"Switch toggled: new state is %@", (newValue) ? @"ON" : @"OFF");
    [self save:self.switcher];
}

- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj {
    [switchObj setCustomKnobImage:[UIImage imageNamed:(switchObj.isOn) ? @"lighting_on" : @"lighting_off"]
          inactiveBackgroundImage:nil
            activeBackgroundImage:nil];
    
}

@end
