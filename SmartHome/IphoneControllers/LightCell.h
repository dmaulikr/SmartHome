//
//  LightCell.h
//  SmartHome
//
//  Created by zhaona on 2016/11/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LightCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *LightNameLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UISwitch *Iphoneswitch;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,assign) int roomID;
@property(nonatomic,strong) NSString * sceneID;
-(void)Iphoneswitch:(UISwitch *)switc;

-(void)dimming:(UISlider *)slider;

//硬件id
@property (weak,nonatomic) NSString *deviceid;

@end
