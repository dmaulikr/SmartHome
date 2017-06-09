//
//  MonitorViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/26.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "MonitorViewController.h"

@interface MonitorViewController ()

@end

@implementation MonitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_video == nil) {
        _video  = [[RTSPPlayer alloc] initWithVideo:self.cameraURL usesTcp:YES];
        _video.outputWidth =  Video_Output_Width;
        _video.outputHeight = Video_Output_Height;
        
        [self setupTimer];
    }else {
        [self startTimer];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopTimer];
    //[_video free];
    //self.delegate = nil;
}

- (void)setupTimer {
    _lastFrameTime = -1;
    
    [_video seekTime:0.0];
    
    _nextFrameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30
                                                       target:self
                                                     selector:@selector(displayNextFrame:)
                                                     userInfo:nil
                                                      repeats:YES];

    [_nextFrameTimer setFireDate:[NSDate distantPast]];
}

- (void)startTimer {
    if ([_nextFrameTimer isValid]) {
        [_nextFrameTimer setFireDate:[NSDate distantPast]];
    }else {
        _nextFrameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30
                                                           target:self
                                                         selector:@selector(displayNextFrame:)
                                                         userInfo:nil
                                                          repeats:YES];
        
        [_nextFrameTimer setFireDate:[NSDate distantPast]];
    }
}

- (void)stopTimer {
    if (_nextFrameTimer) {
        [_nextFrameTimer setFireDate:[NSDate distantFuture]];
        //_nextFrameTimer = nil;
    }
}

-(void)displayNextFrame:(NSTimer *)timer
{
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    if (![_video stepFrame]) {
        [timer invalidate];
        [_video closeAudio];
        return;
    }
    self.cameraImgView.image = _video.currentImage;
    if (_delegate && [_delegate respondsToSelector:@selector(showFullScreenViewByImage:)]) {
        [_delegate showFullScreenViewByImage:_video.currentImage];
    }
    float frameTime = 1.0/([NSDate timeIntervalSinceReferenceDate]-startTime);
    if (_lastFrameTime<0) {
        _lastFrameTime = frameTime;
    } else {
        _lastFrameTime = LERP(frameTime, _lastFrameTime, 0.8);
    }
}

- (void)initUI {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.roomNameLabel.text = self.roomName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)adjustBtnClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(onAdjustBtnClicked:)]) {
        [_delegate onAdjustBtnClicked:sender];
    }
}

- (IBAction)fullScreenBtnClicked:(id)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(onFullScreenBtnClicked:cameraImageView:)]) {
        [_delegate onFullScreenBtnClicked:sender cameraImageView:self.cameraImgView];
    }
}

- (void)dealloc {
    [_nextFrameTimer invalidate];
    _nextFrameTimer = nil;
}

@end
