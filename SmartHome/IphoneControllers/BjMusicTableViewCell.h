//
//  BjMusicTableViewCell.h
//  SmartHome
//
//  Created by zhaona on 2017/4/12.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BjMusicTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *BjMusicNameLb;
@property (weak, nonatomic) IBOutlet UISlider *BjSlider;
@property (weak, nonatomic) IBOutlet UIButton *BjPowerButton;

@end
