//
//  CurtainTableViewCell.m
//  SmartHome
//
//  Created by 逸云科技 on 16/6/2.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "CurtainTableViewCell.h"
#import "SocketManager.h"
#import "SceneManager.h"


@interface CurtainTableViewCell ()


@end
@implementation CurtainTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];

    self.slider.continuous = NO;
    [self.slider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    [self.open addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.close addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.AddcurtainBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    
    [self.slider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.slider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.slider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
    
    [self.open setImage:[UIImage imageNamed:@"bd_icon_wd_on"] forState:UIControlStateSelected];
    [self.open setImage:[UIImage imageNamed:@"bd_icon_wd_off"] forState:UIControlStateNormal];
}


-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.slider]) {
        NSData *data=[[DeviceInfo defaultManager] roll:self.slider.value * 100 deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onCurtainSliderBtnValueChanged:)]) {
            [_delegate onCurtainSliderBtnValueChanged:sender];
        }
    }
    
    if ([sender isEqual:self.open]) {
        
        self.open.selected = !self.open.selected;
        if (self.open.selected) {
            self.slider.value=1;
            [self.open setImage:[UIImage imageNamed:@"bd_icon_wd_on"] forState:UIControlStateSelected];
        }else{
            self.slider.value=0;
            [self.open setImage:[UIImage imageNamed:@"bd_icon_wd_off"] forState:UIControlStateNormal];
        }
        
        NSData *data=[[DeviceInfo defaultManager] toogle:self.open.selected deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onCurtainOpenBtnClicked:)]) {
            [_delegate onCurtainOpenBtnClicked:sender];
        }
    }
    Curtain *device=[[Curtain alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setOpenvalue:self.slider.value * 100];
    
    if ([sender isEqual:self.open]) {
        [device setOpenvalue:100];
    }
   
    if ([sender isEqual:self.AddcurtainBtn]) {
        self.AddcurtainBtn.selected = !self.AddcurtainBtn.selected;
        if (!self.AddcurtainBtn.selected) {
            [self.AddcurtainBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
           
        }else{
            [self.AddcurtainBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
            [_scene setSceneID:[self.sceneid intValue]];
            [_scene setRoomID:self.roomID];
            [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
            
            [_scene setReadonly:NO];
            
            NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
            [_scene setDevices:devices];
            [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
        }
      
    }
  
}


- (IBAction)brightValueChanged:(id)sender {
    self.valueLabel.text = [NSString stringWithFormat:@"%.0f%%",self.slider.value *100];
    if([self.open isSelected])
    {
        self.valueLabel.text = @"100%";
        
    }
    if([self.close isSelected])
    {
        self.valueLabel.text = @"0%";
    }
}

- (IBAction)AddcurtainBtn:(id)sender {
    

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
