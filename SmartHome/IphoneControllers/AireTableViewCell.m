//
//  AireTableViewCell.m
//  SmartHome
//
//  Created by zhaona on 2017/3/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "AireTableViewCell.h"
#import "SQLManager.h"
#import "Aircon.h"
#import "SocketManager.h"
#import "SceneManager.h"

@implementation AireTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
   
    [self.AireSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.AireSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.AireSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
    [self.AireSwitchBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
     [self.AddAireBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
     [self.AireSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
}

- (IBAction)save:(id)sender {
    if (sender == self.AireSwitchBtn) {
        self.AireSwitchBtn.selected = !self.AireSwitchBtn.selected;
        if (self.AireSwitchBtn.selected) {
            [self.AireSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
        }else{
            
            [self.AireSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
        }
    }else if (sender == self.AddAireBtn){
        self.AddAireBtn.selected = !self.AddAireBtn.selected;
        if (self.AddAireBtn.selected) {
            [self.AddAireBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }else{
            [self.AddAireBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
        }
    }else if (sender == self.AireSlider){
        
    }
    
    Aircon *device=[[Aircon alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setWaiting:device.waiting];
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
