//
//  IBeaconController.h
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import <AFNetworking.h>
#import "SocketManager.h"
#import <HomeKit/HomeKit.h>
#import "Light.h"
#import <Reachability/Reachability.h> 

@interface IBeaconController : UIViewController<HMHomeManagerDelegate, HMHomeDelegate,HMAccessoryBrowserDelegate, HMAccessoryDelegate,TcpRecvDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imagev;
@property (strong, nonatomic) IBOutlet UILabel *myLabel;
@property (strong, nonatomic) IBOutlet UILabel *volumeLabel;

@property(nonatomic,strong) NSURLSessionDownloadTask *task;
@property (nonatomic, retain) NSTimer *timer;
@property(nonatomic,strong) Reachability *hostReach;
@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;

@property (weak, nonatomic) IBOutlet UISwitch *powerSwitch;
@property (nonatomic, strong) HMHomeManager *homeManager;
@property (nonatomic, strong) HMHome *primaryHome;
@property (nonatomic, strong) HMCharacteristic *characteristic;

@end
