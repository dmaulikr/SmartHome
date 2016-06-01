//
//  AudioManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AudioManager : NSObject<MPMediaPickerControllerDelegate>

+ (id)defaultManager;
- (void)addSongsToMusicPlayer;

@end
