//
//  LoginController.m
//  SmartHome
//
//  Created by Brustar on 16/6/29.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "LoginController.h"
#import <AFNetworking.h>
#import "IOManager.h"
#import "CryptoManager.h"
#import "DialogManager.h"

@interface LoginController ()
@property (weak, nonatomic) IBOutlet UITextField *user;
@property (weak, nonatomic) IBOutlet UITextField *pwd;

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender
{
    if ([self.user.text isEqualToString:@""])
    {
        [DialogManager showMessage:@"请输入用户名或手机号"];
        return;
    }
    
    if ([self.pwd.text isEqualToString:@""])
    {
        [DialogManager showMessage:@"请输入密码"];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@login",[IOManager httpAddr]];
    // GET
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    // 将数据作为参数传入
    NSDictionary *dict = @{@"username":self.user.text,@"pwd":[self.pwd.text md5]};
    [mgr POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"success:%@",responseObject);
        if ([responseObject[@"Result"] intValue]==1) {
            [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"AuthorToken"] forKey:@"token"];
        }
        [DialogManager showMessage:responseObject[@"Msg"]];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"failure:%@",error);
        [DialogManager showMessage:@"网络错误"];
    }];
}

- (IBAction)reg:(id)sender
{
    CGRect rect = self.view.bounds;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:rect];
    //webView.delegate = self;
    //webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webView];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@""]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];
    [webView loadRequest:request];
}

- (IBAction)forgotPWD:(id)sender
{
    [DialogManager showWeb:@"http://3g.cn"];
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
