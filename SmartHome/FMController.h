//
//  FMController.h
//  SmartHome
//
//  Created by Brustar on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

@interface FMController : UIViewController

@property (nonatomic,weak) NSString *sceneid;
@property (weak, nonatomic) IBOutlet UISlider *volume;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;

@end
