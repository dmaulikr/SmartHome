//
//  NetvController.h
//  SmartHome
//
//  Created by Brustar on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "public.h"

@interface NetvController : UIViewController

@property (nonatomic,weak) NSString *sceneid;
@property (weak, nonatomic) IBOutlet UISlider *volume;
@property (strong, nonatomic) IBeacon *beacon;

@end