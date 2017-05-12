//
//  NowMusicController.m
//  SmartHome
//
//  Created by zhaona on 2017/4/14.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "NowMusicController.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "BgMusic.h"
#import "PackManager.h"
#import "DeviceInfo.h"
#import "AudioManager.h"
#import "SQLManager.h"
#import "HttpManager.h"
#import "Room.h"
#import <AVFoundation/AVFoundation.h>

@interface NowMusicController ()<UITableViewDataSource,UITableViewDelegate, HttpDelegate>
@property (nonatomic,strong) NSArray * bgmusicIDS;
@property (nonatomic,strong) NSMutableArray * bgmusicNameS;
@property (nonatomic,assign) int Volume;
@property (nonatomic,strong) NSMutableArray * AllRooms;
@property (nonatomic,assign) int seleteDeviceId;

@end

@implementation NowMusicController

-(NSArray *)dataArray
{
    if (!_bgmusicIDS) {
        _bgmusicIDS = [NSArray array];
    }

    return _bgmusicIDS;
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];
  
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _deviceArray = [NSMutableArray array];
    _bgmusicNameS = [[NSMutableArray alloc] init];
//    _AllRooms = [SQLManager getAllRoomsInfo];
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio=[AudioManager defaultManager];
        [audio initMusicAndPlay];
    }
    _Volume = 0;
 
    [self fetchPlayingEquipmentList];
     self.MusicTableView.tableFooterView = [UIView new];
}

- (void)fetchPlayingEquipmentList {
    NSString *url = [NSString stringWithFormat:@"%@Cloud/current_player_list.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    
    if (auothorToken.length >0) {
        NSDictionary *dict = @{@"token":auothorToken,
                               @"optype":@(0)
                               };
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dict];
    }
}

#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
            _AllRooms = [[NSMutableArray alloc] init];
    if(tag == 1) {
        [_deviceArray removeAllObjects];
        if ([responseObject[@"result"] intValue] == 0) {
            NSArray *roomList = responseObject[@"current_player_list"];
            if ([roomList isKindOfClass:[NSArray class]]) {
                for (NSDictionary *room in roomList) {
                    
                    if ([room isKindOfClass:[NSDictionary class]]) {
                        NSString *rName = room[@"roomname"];
                        NSArray *equipmentList = room[@"eqinfoList"];
                         [_AllRooms addObject:rName];
                        if ([equipmentList isKindOfClass:[NSArray class]]) {
                            for (NSDictionary *device in equipmentList) {
                                if ([device isKindOfClass:[NSDictionary class]]) {
                                    Device *devInfo = [[Device alloc] init];
                                    devInfo.rName = rName;
                                    devInfo.eID = [device[@"eqid"] intValue];
                                    devInfo.name = device[@"eqname"];
                                    
                                    [_deviceArray addObject:devInfo];
                                    
                                }
                            }
                        }
                        
                    }
                    
                }
            }
            
            [self.MusicTableView reloadData];
        }
    }
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (tag==0) {
        if (proto.action.state == PROTOCOL_VOLUME_UP || proto.action.state == PROTOCOL_VOLUME_DOWN || proto.action.state == PROTOCOL_MUTE)
        {
//            self.volume.value=proto.action.RValue/100.0;
        }
    }
}

#pragma mark - MusicPlayer delegate
-(void)musicPlayerStatedChanged:(NSNotification *)paramNotification
{
    NSLog(@"Player State Changed");
//    self.songTitle.text=[self titleOfNowPlaying];
    NSNumber * stateAsObject = [paramNotification.userInfo objectForKey:@"MPMusicPlayerControllerPlaybackStateKey"];
    NSInteger state = [stateAsObject integerValue];
    switch (state) {
        case MPMusicPlaybackStateStopped:
            
            break;
        case MPMusicPlaybackStatePlaying:
            break;
        case MPMusicPlaybackStatePaused:
            break;
        case MPMusicPlaybackStateInterrupted:
            break;
        case MPMusicPlaybackStateSeekingForward:
            break;
        case MPMusicPlaybackStateSeekingBackward:
            break;
            
        default:
            break;
    }
}

-(NSString*)titleOfNowPlaying
{
    AudioManager *audio=[AudioManager defaultManager];
    if( audio.musicPlayer == nil ) {
        return @"music Player is nil.";
    }
    
    MPMediaItem* item = audio.musicPlayer.nowPlayingItem;
    if( item == nil ) {
        return @"playing.";
    }
    NSString* title = [item valueForKey:MPMediaItemPropertyTitle];
    return title;
}

//减音量
- (IBAction)smallVolume:(id)sender {
    if (_Volume > 0) {
        _Volume -= 10;
        _loseBtn.titleLabel.text = [NSString stringWithFormat:@"%d",_Volume];
    }
    NSData *data=[[DeviceInfo defaultManager] changeVolume:[_loseBtn.titleLabel.text intValue] deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
//    self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio=[AudioManager defaultManager];
        [audio.musicPlayer setVolume:[_loseBtn.titleLabel.text intValue]/100.0];
    }
}
//加音量
- (IBAction)additionVolume:(id)sender {
    if (_Volume <= 100) {
        _Volume += 10;
        _loseBtn.titleLabel.text = [NSString stringWithFormat:@"%d",_Volume];
    }
    
    NSData *data=[[DeviceInfo defaultManager] changeVolume:[_loseBtn.titleLabel.text intValue] deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    //    self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio=[AudioManager defaultManager];
        [audio.musicPlayer setVolume:[_loseBtn.titleLabel.text intValue]/100.0];
    }
}

//开关
- (IBAction)switchPower:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    if (_playState == 0) {
        _playState = 1;
        [btn setBackgroundImage:[UIImage imageNamed:@"close_red"] forState:UIControlStateNormal];
        //发送播放指令
        NSData *data=[[DeviceInfo defaultManager] play:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (BLUETOOTH_MUSIC) {
            AudioManager *audio= [AudioManager defaultManager];
            [[audio musicPlayer] play];
        }
    }else if (_playState == 1) {
        _playState = 0;
        [btn setBackgroundImage:[UIImage imageNamed:@"close_white"] forState:UIControlStateNormal];
        //发送停止指令
        NSData *data=[[DeviceInfo defaultManager] pause:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        if (BLUETOOTH_MUSIC) {
            AudioManager *audio= [AudioManager defaultManager];
            [[audio musicPlayer] pause];
        }
        
    }
}
-(void)dealloc
{
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio= [AudioManager defaultManager];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:audio.musicPlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:audio.musicPlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerVolumeDidChangeNotification object:audio.musicPlayer];
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _AllRooms.count;

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
 
    
    return _deviceArray.count;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.view.bounds.size.width, 50)];
    view.backgroundColor = [UIColor clearColor];
    view.userInteractionEnabled = YES;
    UILabel * NameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 50)];
    NameLabel.textColor = [UIColor whiteColor];
   
    NameLabel.text =_AllRooms[section];
    [view addSubview:NameLabel];
    UIView * view1 = [[UIView alloc] initWithFrame:CGRectMake(10, 49, self.view.bounds.size.width, 1)];
    view1.backgroundColor = [UIColor redColor];
    [view addSubview:view1];
    UIButton * OpenBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-150, 15, 30, 30)];
     OpenBtn.backgroundColor = [UIColor clearColor];
     OpenBtn.tag = 100+1;
    [OpenBtn addTarget:self action:@selector(StopBtn:) forControlEvents:UIControlEventTouchUpInside];
    [OpenBtn setImage:[UIImage imageNamed:@"Video-close"] forState:UIControlStateNormal];
    
    [view addSubview:OpenBtn];
    return view;
}
-(void)StopBtn:(UIButton *)bbt
{
    //关指令
    NSData *data=[[DeviceInfo defaultManager] close:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];

}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
    }
    cell.backgroundColor = [UIColor clearColor];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    Device *devInfo = _deviceArray[indexPath.row];
    cell.textLabel.text = devInfo.name;
    cell.tag = devInfo.eID;
    //cell的点击颜色
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    view.backgroundColor = [UIColor colorWithRed:67/255.0 green:68/255.0 blue:69/255.0 alpha:1];
    
    cell.selectedBackgroundView = view;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
     Device *devInfo = _deviceArray[indexPath.row];
     self.deviceid = [NSString stringWithFormat:@"%d",devInfo.eID];
      NSLog(@"%ld",cell.tag);

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)bgBtnClicked:(id)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(onBgButtonClicked:)]) {
        [_delegate onBgButtonClicked:sender];
    }
}
@end
