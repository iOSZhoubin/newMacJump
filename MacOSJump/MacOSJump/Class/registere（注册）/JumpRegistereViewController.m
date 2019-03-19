//
//  JumpRegistereViewController.m
//  MacOSJump
//
//  Created by jumpapp1 on 2019/3/19.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "JumpRegistereViewController.h"
#import "ChooseConmpanyWindowController.h"
#import "AppDelegate.h"


@interface JumpRegistereViewController ()<ChooseCompanyDelegate>


@property (strong,nonatomic) ChooseConmpanyWindowController *choosePeople;

@property (strong,nonatomic) NSMutableDictionary *dataDict;
//使用人
@property (weak) IBOutlet NSTextField *userName;
//邮箱
@property (weak) IBOutlet NSTextField *mail;
//设备类型
@property (weak) IBOutlet NSTextField *deviceType;
//联系电话
@property (weak) IBOutlet NSTextField *phoneNum;
//计算机所在地
@property (weak) IBOutlet NSTextField *computerAddress;
//部门名称
@property (weak) IBOutlet NSTextField *companyName;
//备注
@property (weak) IBOutlet NSTextField *remark;

@end

@implementation JumpRegistereViewController


-(NSMutableDictionary *)dataDict{
    
    if(!_dataDict){
        
        _dataDict = [NSMutableDictionary dictionary];
    }
    
    return _dataDict;
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    self.choosePeople = [[ChooseConmpanyWindowController alloc]initWithWindowNibName:@"ChooseConmpanyWindowController"];
    
    self.choosePeople.delegate = self;
    
}


//注册

- (IBAction)backAction:(NSButton *)sender {
    
    if(self.userName.stringValue.length < 1 || self.deviceType.stringValue.length < 1 || self.phoneNum.stringValue.length < 1 || self.companyName.stringValue.length < 1){
        
        [self show:@"提示" andMessage:@"必填字段不能为空"];
        
        return;
    }
    
    
    [self registerAction];
}

#pragma mark --- 选择部门

- (IBAction)chooseAction:(NSButton *)sender {
    
    [self.choosePeople.window orderFront:nil];//显示要跳转的窗口
    
    [[self.choosePeople window] center];//显示在屏幕中间
    
}

#pragma mark --- 选择部门代理

-(void)selectCompany:(NSMutableDictionary *)selectDict{
    
    self.dataDict[@"companyName"] = SafeString(selectDict[@"text"]);
    self.dataDict[@"companyId"] = SafeString(selectDict[@"id"]);
    
    self.companyName.stringValue = SafeString(self.dataDict[@"companyName"]);
}



#pragma mark --- 注册方法

-(void)registerAction{
    
    L2CWeakSelf(self);
    
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    
    paramters[@"name"] = SafeString(self.userName.stringValue);
    paramters[@"departmentName"] = SafeString(self.dataDict[@"companyName"]);
    paramters[@"departmentId"] = SafeString(self.dataDict[@"companyId"]);
    paramters[@"address"] = SafeString(self.computerAddress.stringValue);
    paramters[@"phoneNumber"] = SafeString(self.phoneNum.stringValue);
    paramters[@"email"] = SafeString(self.mail.stringValue);
    paramters[@"deviceType"] = SafeString(self.deviceType.stringValue);
    paramters[@"remark"] = SafeString(self.remark.stringValue);
    
    
    NSDictionary *defaultDict = [JumpKeyChain getKeychainDataForKey:@"userInfo"];
    
    NSString *port = SafeString(defaultDict[@"port"]);
    NSString *ipAddress = SafeString(defaultDict[@"ipAddress"]);
    
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",ipAddress,port,Mac_Registered];
    
    [AFNHelper macPost:urlStr parameters:paramters success:^(id responseObject) {
        
        if([responseObject[@"message"] isEqualToString:@"ok"]){
            
            AppDelegate *adelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
            
            [[adelegate.mainWindowC window] makeKeyAndOrderFront:nil];
            
            [[adelegate.mainWindowC window] center];//显示在屏幕中间
            
        }else{
            
            [weakself show:@"提示" andMessage:@"注册失败"];
            
        }
        
    } andFailed:^(id error) {
        
        [weakself show:@"提示" andMessage:@"注册失败"];
    }];
}



#pragma mark --- 提示框

-(void)show:(NSString *)title andMessage:(NSString *)message{
    
    NSAlert *alert = [[NSAlert alloc]init];
    
    alert.messageText = title;
    
    alert.informativeText = message;
    
    //设置提示框的样式
    alert.alertStyle = NSAlertStyleWarning;
    
//    [alert beginSheetModalForWindow:self.window completionHandler:nil];
}


@end
