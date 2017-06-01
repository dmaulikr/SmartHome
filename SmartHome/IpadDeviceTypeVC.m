//
//  IpadDeviceTypeVC.m
//  SmartHome
//
//  Created by zhaona on 2017/5/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IpadDeviceTypeVC.h"
#import "IpadDeviceTypeCell.h"
#import "SQLManager.h"

@interface IpadDeviceTypeVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray * roomList;
@property (nonatomic,strong) NSArray * SubTypeNameArr;
@property (nonatomic,strong) NSArray * SubTypeIconeImage;
@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, readonly) UIButton *naviLeftBtn;

@end

@implementation IpadDeviceTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.SubTypeNameArr = @[@"灯光",@"影音",@"环境",@"窗帘",@"智能单品",@"安防"];
    self.SubTypeIconeImage = @[@"icon_light_nol",@"icon_vdo_nol",@"icon_airconditioner_nol",@"icon_windowcurtains_nol",@"icon_Intelligence_nol",@"ipad-icon_safe_nol"];
      self.roomList = [SQLManager getDevicesSubTypeNamesWithRoomID:self.roomID];
      [self setupNaviBar];

}
- (void)setupNaviBar {
    
    [self setNaviBarTitle:[UD objectForKey:@"homename"]]; //设置标题
    _naviLeftBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"backBtn" imgHighlight:@"backBtn" target:self action:@selector(leftBtnClicked:)];
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
    [self setNaviBarLeftBtn:_naviLeftBtn];
    [self setNaviBarRightBtn:_naviRightBtn];
}
-(void)leftBtnClicked:(UIButton *)leftBtn
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        
    }];
}
-(void)rightBtnClicked:(UIButton *)rightBtn
{

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

//    return self.roomList.count;
    return self.SubTypeNameArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IpadDeviceTypeCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.SubTypeNameLabel.text = self.SubTypeNameArr[indexPath.row];
    cell.SubTypeIconeImage.image = [UIImage imageNamed:self.SubTypeIconeImage[indexPath.row]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(IpadDeviceType:selected:)]) {
    
        [self.delegate IpadDeviceType:self selected:indexPath.row];
    }
}

@end
