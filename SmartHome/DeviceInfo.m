//
//  IBeacon.m
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DeviceInfo.h"
#import "sys/utsname.h"
#import <Reachability/Reachability.h>
#import "PackManager.h"
#import "ProtocolManager.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "FMDatabase.h"

@implementation DeviceInfo

+ (id)defaultManager
{
    static DeviceInfo *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void) netReachbility
{
    Reachability *curReach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    NetworkStatus status = [curReach currentReachabilityStatus];
    self.reachbility=status;
}

-(void)initConfig
{
    //创建sqlite数据库及结构
    [self initSQlite];
    
    //先判断版本号
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSString *userHostID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserHostID"];
    NSString *url = [NSString stringWithFormat:@"%@GetConfigVersion.aspx",[IOManager httpAddr]];
    /*
    NSDictionary *dict = @{@"AuthorToken":authorToken,@"UserHostID":userHostID};
    
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    [http sendPost:url param:dict];
    */
    //更新设备，房间，场景表，protocol,写入sqlite
    
    //缓存协议
    [[ProtocolManager defaultManager] fetchAll];
}

-(void)initSQlite
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
    if ([db open]) {
        NSString *sqlRom=@"CREATE TABLE IF NOT EXISTS Rooms(ID INT PRIMARY KEY NOT NULL, NAME TEXT NOT NULL, \"PM25\" INTEGER, \"NOISE\" INTEGER, \"TEMPTURE\" INTEGER, \"CO2\" INTEGER, \"moisture\" INTEGER)";
        NSString *sqlChannel=@"CREATE TABLE IF NOT EXISTS Channels (\"id\" INTEGER PRIMARY KEY  NOT NULL  UNIQUE , \"Channel_name\" TEXT, \"Channel_id\" INTEGER, \"Channel_pic\" TEXT, \"parent\" CHAR(2) NOT NULL  DEFAULT TV, \"isFavorite\" BOOL DEFAULT 0);";
        NSString *sqlDevice=@"CREATE TABLE IF NOT EXISTS Devices(ID INT PRIMARY KEY NOT NULL, NAME TEXT NOT NULL, \"sn\" TEXT, \"birth\" DATETIME, \"guarantee\" DATETIME, \"model\" TEXT, \"price\" FLOAT, \"purchase\" DATETIME, \"producer\" TEXT, \"gua_tel\" TEXT, \"power\" INTEGER, \"current\" FLOAT, \"voltage\" INTEGER, \"protocol\" TEXT)";
        NSString *sqlScene=@"CREATE TABLE IF NOT EXISTS \"Scenes\" (\"ID\" INT PRIMARY KEY  NOT NULL ,\"NAME\" TEXT NOT NULL ,\"room\" INT NOT NULL ,\"pic\" CHAR(50) DEFAULT (null) ,\"isFavorite\" Key Boolean DEFAULT (0) )";
        NSString *sqlProtocol=@"CREATE TABLE IF NOT EXISTS [t_protocol_config]([rid] [int] IDENTITY(1,1) NOT NULL,[eid] [int] NULL,[enumber] [varchar](64) NULL,[ename] [varchar](64) NULL,[etype] [varchar](64) NULL,[actname] [varchar](256) NULL,[actcode] [varchar](256) NULL, \"actKey\" VARCHAR)";
        NSArray *sqls=@[sqlRom,sqlChannel,sqlDevice,sqlScene,sqlProtocol];
        //4.创表
        for (NSString *sql in sqls) {
            BOOL result=[db executeUpdate:sql];
            if (result) {
                NSLog(@"创表成功");
            }else{
                NSLog(@"创表失败");
            }
        }
    }else{
        NSLog(@"Could not open db.");
    }
    
    [db closeOpenResultSets];
    [db close];
}

-(void) httpHandler:(id) responseObject{
    if([responseObject[@"Result"] intValue] == 0)
    {
        [IOManager writeUserdefault:responseObject[@"vEquipment"] forKey:@"vEquipment"];
        [IOManager writeUserdefault:responseObject[@"vRoom"] forKey:@"vRoom"];
        [IOManager writeUserdefault:responseObject[@"vScene"] forKey:@"vScene"];
        [IOManager writeUserdefault:responseObject[@"vTVChannel"] forKey:@"vTVChannel"];
        [IOManager writeUserdefault:responseObject[@"vClient"] forKey:@"vClient"];
    }else{
        [MBProgressHUD showError:responseObject[@"Msg"]];
    }
}
//取设备机型
- (void) deviceGenaration
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"])    self.genaration = iPhone;
    if ([deviceString isEqualToString:@"iPhone1,2"])    self.genaration = iPhone3G;
    if ([deviceString isEqualToString:@"iPhone2,1"])    self.genaration = iPhone3GS;
    if ([deviceString isEqualToString:@"iPhone3,1"])    self.genaration = iPhone4;
    if ([deviceString isEqualToString:@"iPhone4,1"])    self.genaration = iPhone4S;
    if ([deviceString isEqualToString:@"iPhone5,2"] || [deviceString isEqualToString:@"iPhone5,2"])    self.genaration = iPhone5;
    if ([deviceString isEqualToString:@"iPhone5,3"] || [deviceString isEqualToString:@"iPhone5,4"])   self.genaration = iPhone5C;
    if ([deviceString isEqualToString:@"iPhone6,1"] || [deviceString isEqualToString:@"iPhone6,2"])   self.genaration = iPhone5S;
    if ([deviceString isEqualToString:@"iPhone7,1"])   self.genaration = iPhone6Plus;
    if ([deviceString isEqualToString:@"iPhone7,2"])    self.genaration = iPhone6;
    if ([deviceString isEqualToString:@"iPhone8,1"])    self.genaration = iPhone6S;
    if ([deviceString isEqualToString:@"iPhone8,2"])    self.genaration = iPhone6SPlus;
    
    if ([deviceString isEqualToString:@"iPod1,1"])      self.genaration = iPod;
    if ([deviceString isEqualToString:@"iPod2,1"])      self.genaration = iPod2;
    if ([deviceString isEqualToString:@"iPod3,1"])      self.genaration = iPod3;
    if ([deviceString isEqualToString:@"iPod4,1"])      self.genaration = iPod4;
    if ([deviceString isEqualToString:@"iPod5,1"])      self.genaration = iPod5;
    
    if ([deviceString isEqualToString:@"iPad1,1"])      self.genaration = iPad;
    if ([deviceString isEqualToString:@"iPad2,1"] || [deviceString isEqualToString:@"iPad2,2"] || [deviceString isEqualToString:@"iPad2,3"] || [deviceString isEqualToString:@"iPad2,4"])      self.genaration = iPad2;
    if ([deviceString isEqualToString:@"iPad2,5"] || [deviceString isEqualToString:@"iPad2,6"] || [deviceString isEqualToString:@"iPad2,7"] )      self.genaration = iPadMini;
    if ([deviceString isEqualToString:@"iPad3,1"] || [deviceString isEqualToString:@"iPad3,2"] || [deviceString isEqualToString:@"iPad3,3"])
        self.genaration = iPad3;
    if( [deviceString isEqualToString:@"iPad3,4"] || [deviceString isEqualToString:@"iPad3,5"] || [deviceString isEqualToString:@"iPad3,6"])      self.genaration = iPad4;
    if ([deviceString isEqualToString:@"iPad4,1"] || [deviceString isEqualToString:@"iPad4,2"] || [deviceString isEqualToString:@"iPad4,3"])    self.genaration = iPadAir;
    if ([deviceString isEqualToString:@"iPad5,3"] || [deviceString isEqualToString:@"iPad5,4"])      self.genaration = iPadAir2;
    if ([deviceString isEqualToString:@"iPad4,4"]
        ||[deviceString isEqualToString:@"iPad4,5"]
        ||[deviceString isEqualToString:@"iPad4,6"])      self.genaration = iPadMini2;
    if ([deviceString isEqualToString:@"iPad4,7"]
        ||[deviceString isEqualToString:@"iPad4,8"]
        ||[deviceString isEqualToString:@"iPad4,9"])      self.genaration = iPadMini3;
    
    if ([deviceString isEqualToString:@"iPad6,3"] || [deviceString isEqualToString:@"iPad6,4"] || [deviceString isEqualToString:@"iPad6,7"] || [deviceString isEqualToString:@"iPad6,8"]) self.genaration = iPadPro;

    NSLog(@"NOTE: device type: %@", deviceString);
}

-(NSData *) action:(uint8_t)action deviceID:(NSString *)deviceID
{
    Proto proto=createProto();
    ProtocolManager *manager=[ProtocolManager defaultManager];
    proto.cmd=0x03;
    proto.action.state=action;
    
    proto.deviceID=CFSwapInt16BigToHost([manager queryDeviceHexIDs:deviceID]);
    proto.deviceType=[[manager queryDeviceTypes:deviceID] intValue];
    proto.masterID=CFSwapInt16BigToHost(0x22b8);//self.masterID;
    return dataFromProtocol(proto);
}

-(NSData *) action:(uint8_t)action deviceID:(NSString *)deviceID value:(uint8_t)value
{
    Proto proto=createProto();
    ProtocolManager *manager=[ProtocolManager defaultManager];
    proto.cmd=0x03;
    proto.action.state=action;
    proto.action.RValue=value;
    proto.deviceID=CFSwapInt16BigToHost([[manager queryDeviceTypes:deviceID] intValue]);
    proto.deviceType=[manager queryDeviceHexIDs:deviceID];
    proto.masterID=CFSwapInt16BigToHost(self.masterID);
    return dataFromProtocol(proto);
}

#pragma mark - public
//TV,DVD,NETV,BGMusic
-(NSData *) previous:(NSString *)deviceID
{
    return [self action:PROTOCOL_PREVIOUS deviceID:deviceID];
}

-(NSData *) forward:(NSString *)deviceID
{
    return [self action:PROTOCOL_FORWARD deviceID:deviceID];
}

-(NSData *) backward:(NSString *)deviceID
{
    return [self action:PROTOCOL_BACKWARD deviceID:deviceID];
}

-(NSData *) next:(NSString *)deviceID
{
    return [self action:PROTOCOL_FORWARD deviceID:deviceID];
}

-(NSData *) play:(NSString *)deviceID
{
    return [self action:PROTOCOL_PLAY deviceID:deviceID];
}

-(NSData *) pause:(NSString *)deviceID
{
    return [self action:PROTOCOL_PAUSE deviceID:deviceID];
}

-(NSData *) stop:(NSString *)deviceID
{
    return [self action:PROTOCOL_STOP deviceID:deviceID];
}

-(NSData *) changeVolume:(uint8_t)percent deviceID:(NSString *)deviceID
{
    return [self action:PROTOCOL_VOLUME deviceID:deviceID value:percent];
}

//TV,DVD,NETV
-(NSData *) sweepLeft:(NSString *)deviceID
{
    return [self action:PROTOCOL_LEFT deviceID:deviceID];
}

-(NSData *) sweepRight:(NSString *)deviceID
{
    return [self action:PROTOCOL_RIGHT deviceID:deviceID];
}

-(NSData *) sweepUp:(NSString *)deviceID
{
    return [self action:PROTOCOL_UP deviceID:deviceID];
}

-(NSData *) sweepDown:(NSString *)deviceID
{
    return [self action:PROTOCOL_DOWN deviceID:deviceID];
}

#pragma mark - lighter
-(NSData *) toogleLight:(uint8_t)toogle deviceID:(NSString *)deviceID
{
    return [self action:toogle deviceID:deviceID];
}

-(NSData *) changeColor:(uint8_t)color deviceID:(NSString *)deviceID
{
    return [self action:color deviceID:deviceID];
}

-(NSData *) changeBright:(uint8_t)bright deviceID:(NSString *)deviceID
{
    return [self action:bright deviceID:deviceID];
}

#pragma mark - curtain
-(NSData *) roll:(uint8_t)percent deviceID:(NSString *)deviceID
{
    return [self action:0x2A deviceID:deviceID value:percent];
}

-(NSData *) open:(NSString *)deviceID
{
    return [self action:0x64 deviceID:deviceID];
}

-(NSData *) close:(NSString *)deviceID
{
    return [self action:0x00 deviceID:deviceID];
}

#pragma mark - TV
-(NSData *) switchProgram:(uint8_t)program deviceID:(NSString *)deviceID
{
    return [self action:0x3A deviceID:deviceID value:program];
}

-(NSData *) changeTVolume:(uint8_t)percent deviceID:(NSString *)deviceID
{
    return [self action:0x3A deviceID:deviceID value:percent];
}

#pragma mark - DVD
-(NSData *) home:(NSString *)deviceID
{
    return [self action:0x20 deviceID:deviceID];
}

-(NSData *) pop:(NSString *)deviceID
{
    return [self action:0x30 deviceID:deviceID];
}

#pragma mark - NETV
-(NSData *) NETVhome:(NSString *)deviceID
{
    return [self action:0x11 deviceID:deviceID];
}

-(NSData *) back:(NSString *)deviceID
{
    return [self action:0x10 deviceID:deviceID];
}

#pragma mark - FM
-(NSData *) switchFMProgram:(uint8_t)program deviceID:(NSString *)deviceID
{
    return [self action:program deviceID:deviceID];
}

#pragma mark - Guard
-(NSData *) toogle:(uint8_t)toogle deviceID:(NSString *)deviceID
{
    return [self action:toogle deviceID:deviceID];
}

#pragma mark - Air
-(NSData *) toogleAirCon:(uint8_t)toogle deviceID:(NSString *)deviceID
{
    return [self action:toogle deviceID:deviceID];
}
-(NSData *) changeTemperature:(uint8_t)temperature deviceID:(NSString *)deviceID
{
    return [self action:temperature deviceID:deviceID];
}
-(NSData *) changeDirect:(uint8_t)direct deviceID:(NSString *)deviceID
{
    return [self action:direct deviceID:deviceID];
}
-(NSData *) changeSpeed:(uint8_t)speed deviceID:(NSString *)deviceID
{
    return [self action:speed deviceID:deviceID];
}
-(NSData *) changeMode:(uint8_t)mode deviceID:(NSString *)deviceID
{
    return [self action:mode deviceID:deviceID];
}
-(NSData *) changeInterval:(uint8_t)interval deviceID:(NSString *)deviceID
{
    return [self action:interval deviceID:deviceID];
}

@end