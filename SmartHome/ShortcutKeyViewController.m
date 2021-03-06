//
//  ShortcutKeyViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/3/28.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "ShortcutKeyViewController.h"
#import "SQLManager.h"
#import "ShortcutKeyCell.h"
#import "Scene.h"

@interface ShortcutKeyViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray * seleteSceneArray;
@property (nonatomic,strong) NSArray * AllSceneArray;
@property (nonatomic,strong) NSMutableArray * sceneArr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) UIButton * naviRightBtn;

@end

@implementation ShortcutKeyViewController
{
       NSArray * DataUrl;

}
-(NSArray *)AllSceneArray
{
    if (_AllSceneArray == nil) {
        _AllSceneArray = [NSArray array];
    }
    
    return _AllSceneArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
     _AllSceneArray = [SQLManager getAllScene];
    _seleteSceneArray = [[NSMutableArray alloc] init];
    [self setupNaviBar];

    
}
- (void)setupNaviBar {
    [self setNaviBarTitle:@"首页场景快捷键"]; //设置标题
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
    _naviRightBtn.tintColor = [UIColor whiteColor];
    //    [self setNaviBarLeftBtn:_naviLeftBtn];
    [self setNaviBarRightBtn:_naviRightBtn];
}
-(void)rightBtnClicked:(UIButton *)bbi
{
    NSString *filepath;
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSMutableArray * data = [[NSMutableArray alloc] init];
    if (filepath) {
        [data removeAllObjects];
    }
    data = self.seleteSceneArray;
    filepath= [docPath stringByAppendingPathComponent:@"data.plist"];
    
    [data writeToFile:filepath atomically:YES];
    [self.navigationController popViewControllerAnimated:YES];

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _seleteSceneArray.count;
    }
    return _AllSceneArray.count;
}

-(void)viewDidLayoutSubviews {
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 44;
}
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return @"在下方选择你需要添加到首页的场景";
//    }
//    return @"家里所有的场景";
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ShortcutKeyCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ShortcutKeyCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:34/255.0 alpha:1];
    if (indexPath.section == 0) {
        cell.sceneNameImage.image = [UIImage imageNamed:@"logo"];
        cell.sceneNameLabel.text = _seleteSceneArray[indexPath.row];
        [self.tableView reloadData];
    }if (indexPath.section == 1) {
        Scene * scene = _AllSceneArray[indexPath.row];
        cell.sceneNameLabel.text = scene.sceneName;
        cell.sceneNameImage.image = [UIImage imageNamed:@"logo"];
//        cell.sceneNameImage.image = [UIImage imageNamed:scene.picName];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShortcutKeyCell * cell = (ShortcutKeyCell *)[tableView cellForRowAtIndexPath:indexPath];
         Scene * scene = _AllSceneArray[indexPath.row];
         cell.sceneNameLabel.text = scene.sceneName;
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [_seleteSceneArray insertObject:cell.sceneNameLabel.text atIndex:0];
        }
     
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
   
    if (_seleteSceneArray.count >3) {
        UIAlertController * alerController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"先去掉一个再去选择" preferredStyle:UIAlertControllerStyleAlert];
        
        [alerController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alerController animated:YES completion:^{
            
        }];
    }
}

- (IBAction)saveBarBtn:(id)sender {
    NSString *filepath;
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSMutableArray * data = [[NSMutableArray alloc] init];
    if (filepath) {
        [data removeAllObjects];
    }
     data = self.seleteSceneArray;
     filepath= [docPath stringByAppendingPathComponent:@"data.plist"];
   
    [data writeToFile:filepath atomically:YES];
    [self.navigationController popViewControllerAnimated:YES];
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

@end
