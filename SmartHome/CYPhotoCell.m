//
//  CYPhotoCell.m
//  自定义流水布局
//
//  Created by 葛聪颖 on 15/11/13.
//  Copyright © 2015年 聪颖不聪颖. All rights reserved.
//

#import "CYPhotoCell.h"
#import "SceneManager.h"
#import "Scene.h"
#import "SQLManager.h"
#import "MBProgressHUD+NJ.h"


@interface CYPhotoCell()<UIGestureRecognizerDelegate,UIActionSheetDelegate>

@end

@implementation CYPhotoCell

- (void)awakeFromNib {
    [super awakeFromNib];

}
//删除
- (IBAction)doDeleteBtn:(id)sender {
    
   
    if (_delegate && [_delegate respondsToSelector:@selector(sceneDeleteAction:)]) {
          [self.delegate sceneDeleteAction:self];
    }
}

//开关
- (IBAction)powerBtn:(id)sender {
   
    NSString *isDemo = [UD objectForKey:IsDemo];
    if ([isDemo isEqualToString:@"YES"]) {
        [MBProgressHUD showSuccess:@"真实用户才可以操作"];
    }else{
       if (self.sceneStatus == 0) { //点击前，场景是关闭状态，需打开场景
//            [self.powerBtn setBackgroundImage:[UIImage imageNamed:@"close_red"] forState:UIControlStateNormal];
                [[SceneManager defaultManager] startScene:self.sceneID];//打开场景
                [SQLManager updateSceneStatus:1 sceneID:self.sceneID];//更新数据库
            
        }else if (self.sceneStatus == 1) { //点击前，场景是打开状态，需关闭场景
//            [self.powerBtn setBackgroundImage:[UIImage imageNamed:@"close_white"] forState:UIControlStateNormal];
            [[SceneManager defaultManager] poweroffAllDevice:self.sceneID];//关闭场景
            [SQLManager updateSceneStatus:0 sceneID:self.sceneID];//更新数据库
        }
        if (_delegate && [_delegate respondsToSelector:@selector(refreshTableView:)]) {
            [self.delegate refreshTableView:self];
        }
    }

}
//定时
- (IBAction)timingBtn:(id)sender {
    
    NSString *isDemo = [UD objectForKey:IsDemo];
    if ([isDemo isEqualToString:@"YES"]) {
        [MBProgressHUD showSuccess:@"真实用户才可以操作"];
    }else{
        self.seleteSendPowBtn.selected = !self.seleteSendPowBtn.selected;
        if (self.seleteSendPowBtn.selected) {
            [self.seleteSendPowBtn setBackgroundImage:[UIImage imageNamed:@"alarm clock2"] forState:UIControlStateSelected];
        }else{
            [self.seleteSendPowBtn setBackgroundImage:[UIImage imageNamed:@"alarm clock1"] forState:UIControlStateNormal];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(onTimingBtnClicked:sceneID:)]) {
            [_delegate onTimingBtnClicked:sender sceneID:self.sceneID];
        }
    }
    
    
}

@end
