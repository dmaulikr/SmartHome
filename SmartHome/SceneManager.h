//
//  SceneManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/18.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "public.h"
#import "Light.h"
#import "Curtain.h"
#import "TV.h"
#import "DVD.h"
#import "Radio.h"
#import "Netv.h"
#import "FMDB.h"
#import "EntranceGuard.h"
#import "Aircon.h"
#import "BgMusic.h"
#import "Amplifier.h"

@interface SceneManager : NSObject

+ (id) defaultManager;

- (void) addScene:(Scene *)scene withName:(NSString *)name withPic:(NSString *)picurl;

- (void) delScene:(Scene *)scene;

- (void) editScene:(Scene *)scene;

- (void) favoriteScene:(Scene *)newScene withName:(NSString *)name;

- (Scene *)readSceneByID:(int)sceneid;

-(NSArray *)addDevice2Scene:(Scene *)scene withDeivce:(id)device withId:(int)deviceID;

-(void) startScene:(int)sceneid;
-(void) poweroffAllDevice:(int)sceneid;

//得到所有场景
+(NSArray *)allSceneModels;
+(NSArray *)devicesBySceneID:(int)sId;
+(Scene *)sceneBySceneID:(int)sId;
//根据房间ID的到所有的场景
+ (NSArray *)getAllSceneWithRoomID:(int)roomID;


//从数据库中删除场景
+(BOOL)deleteScene:(int)sceneId;
+(NSArray *)getScensByRoomId:(int)roomId;
+(NSArray *)getFavorScene;
@end
