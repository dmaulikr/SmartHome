//
//  UIImagePickerController+LandScapeImagePicker.h
//  SmartHome
//
//  Created by 逸云科技 on 16/8/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImagePickerController (LandScapeImagePicker)
- (BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;

@end
