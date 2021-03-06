//
//  DeviceListController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/22.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceListController : UIViewController
@property (strong, nonatomic) NSMutableArray *devices;
@property (strong, nonatomic) NSArray *segues;
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,assign) int deviceid;
@property (nonatomic,assign) NSInteger roomid;
@end
