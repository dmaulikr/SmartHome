//
//  SocketManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SocketManager.h"
#import "AsyncUdpSocket.h"
#import "PackManager.h"
#import <Reachability/Reachability.h>
#import "MBProgressHUD+NJ.h"

@implementation SocketManager

+ (id)defaultManager {
    static SocketManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

// socket连接
-(void)socketConnectHost
{
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    NSError *error = nil;
    [self.socket connectToHost:self.socketHost onPort:self.socketPort withTimeout:3 error:&error];
}

// 切断socket
-(void)cutOffSocket{
    self.socket.userData = SocketOfflineByUser;// 声明是由用户主动切断
    [self.connectTimer invalidate];
    [self.socket disconnect];
}

// 心跳连接
-(void)longConnectToSocket
{
    // 根据服务器要求发送固定格式的数据，假设为指令@"longConnect"，但是一般不会是这么简单的指令
    NSString *longConnect = @"longConnect\r\n";
    NSData   *dataStream  = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:dataStream withTimeout:1 tag:1];
    [self.socket readDataToData:[AsyncSocket CRLFData] withTimeout:1 tag:1];
}

-(void)connectUDP:(int)port
{
    NSError *bindError = nil;
    AsyncUdpSocket *udpSocket=[[AsyncUdpSocket alloc]initWithDelegate:self];
    [udpSocket bindToPort:40000 error:&bindError];
    
    if (bindError) {
        NSLog(@"bindError = %@",bindError);
    }
    
    [udpSocket receiveWithTimeout:5000 tag:1]; //接收数据
}

-(void)initTcp:(NSString *)addr port:(int)port mode:(int)mode delegate:(id)delegate
{
    self.socketHost = addr;
    self.socketPort = port;
    self.delegate=delegate;
    self.netMode=mode;
    // 在连接前先进行手动断开
    [self cutOffSocket];
    
    // 确保断开后再连，如果对一个正处于连接状态的socket进行连接，会出现崩溃
    [self socketConnectHost];
}

- (void) connectTcp
{
    //请求协调服务器
    [self initTcp:[IOManager tcpAddr] port:[IOManager tcpPort] mode:outDoor delegate:nil];
    Proto proto=createProto();
    proto.cmd=0x00;
    DeviceInfo *device=[DeviceInfo defaultManager];
    proto.masterID=device.masterID;
    NSData *data=dataFromProtocol(proto);
    [self.socket writeData:data withTimeout:1 tag:1000];
    [self.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:1 tag:1000];
}

- (void) connectAfterLogined
{
    DeviceInfo *device=[DeviceInfo defaultManager];
    
    if (device.reachbility == ReachableViaWiFi) {
        [self connectUDP:40000];
    }else if (device.reachbility == ReachableViaWWAN){
        [self connectTcp];
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查你的网络设置"];
    }
}

- (void) handleUDP:(NSData *)data
{
    if ([PackManager checkProtocol:data cmd:0x80]) {
        //Proto proto=protocolFromData(data);

        NSData *masterID=[data subdataWithRange:NSMakeRange(3, 4)];
        NSData *ip=[data subdataWithRange:NSMakeRange(8, 4)];
        NSData *port=[data subdataWithRange:NSMakeRange(12, 2)];
        
        
        DeviceInfo *info=[DeviceInfo defaultManager];
        info.masterID=(long)[PackManager NSDataToUInt:masterID];
        info.masterIP=[PackManager NSDataToIP:ip];
        info.masterPort=(int)[PackManager NSDataToUInt:port];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLong:[PackManager NSDataToUInt:masterID]] forKey:@"masterID"];
        [self initTcp:[PackManager NSDataToIP:ip] port:(int)[PackManager NSDataToUInt:port] mode:atHome delegate:nil];
    }else{
        [self connectTcp];
    }
}

- (void) handleTCP:(NSData *)data
{
    if ([PackManager checkProtocol:data cmd:0x00]) {
        NSData *ip=[data subdataWithRange:NSMakeRange(8, 4)];
        NSData *port=[data subdataWithRange:NSMakeRange(12, 2)];
        
        [[NSUserDefaults standardUserDefaults] setObject:[PackManager NSDataToIP:ip] forKey:@"subIP"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLong:[PackManager NSDataToUInt:port]] forKey:@"subPort"];
        [self initTcp:[PackManager NSDataToIP:ip] port:(int)[PackManager NSDataToUInt:port] mode:outDoor delegate:nil];
    }
}

#pragma mark  - TCP delegate
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket连接成功,host:%@,port:%d",host,port);
    // 每隔30s像服务器发送心跳包
    //self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
    //[self.connectTimer fire];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //NSString *recv=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"received data:%@",data);
    if (tag==1000) {
        [self handleTCP:data];
        return;
    }
    [self.delegate recv:data withTag:tag];
}

-(void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(long)partialLength tag:(long)tag
{
    NSLog(@"Received bytes: %ld",partialLength);
}

-(void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"sorry the connect is failure %ld",sock.userData);
    if (sock.userData == SocketOfflineByServer) {// 服务器掉线，重连
        [self socketConnectHost];
    }else if (sock.userData == SocketOfflineByUser) {// 如果由用户断开，不进行重连
        return;
    }
}

#pragma mark  - UDP delegate
-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"onUdpSocket:%@",data);
    [self handleUDP:data];
    return YES;
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotSendDataWithTag.");
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotReceiveDataWithTag.");
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"didSendDataWithTag.");
}

-(void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
    NSLog(@"onUdpSocketDidClose.");
    [self connectTcp];
}

@end
