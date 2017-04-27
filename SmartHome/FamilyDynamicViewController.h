//
//  FamilyDynamicViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/26.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "CustomViewController.h"
#import "SQLManager.h"
#import "MonitorViewController.h"

@interface FamilyDynamicViewController : CustomViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *cameraList;
@property (nonatomic, strong) NSMutableArray *cameraIDArray;
@end
