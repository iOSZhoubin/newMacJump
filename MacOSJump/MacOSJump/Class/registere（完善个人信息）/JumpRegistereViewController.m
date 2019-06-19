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
#import "FirstPageTabController.h"


@interface JumpRegistereViewController ()<ChooseCompanyDelegate>


@property (strong,nonatomic) ChooseConmpanyWindowController *choosePeople;

@property (strong,nonatomic) FirstPageTabController *firstWc;

@property (strong,nonatomic) NSMutableArray *titleArray;

@property (strong,nonatomic) NSMutableDictionary *dataDict;

@property (copy,nonatomic) NSString *accout;

//使用人
@property (weak) IBOutlet NSTextField *userName;
//邮箱
@property (weak) IBOutlet NSTextField *mail;
//设备类型
@property (weak) IBOutlet NSTextField *deviceType;
//联系电话
@property (weak) IBOutlet NSTextField *phoneNum;
//设备位置
@property (weak) IBOutlet NSTextField *computerAddress;
//部门名称
@property (weak) IBOutlet NSTextField *companyName;
//备注
@property (weak) IBOutlet NSTextField *remark;
//选择部门
@property (weak) IBOutlet NSButton *chooseDepart;


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
    
    [self getTitleNameArray];//获取注册列表
}


#pragma mark --- 保存

- (IBAction)backAction:(NSButton *)sender {
    
    NSString *isgo = @"1";
    
    for (NSDictionary *titleDict in self.titleArray) {
        
        NSString *title = SafeString(titleDict[@"title"]);
        NSString *type = SafeString(titleDict[@"type"]);
        
        if([title isEqualToString:@"使用人"] && SafeString(self.userName.stringValue).length < 1 && [type isEqualToString:@"2"]){
            
            [self show:@"提示" andMessage:@"请输入使用人"];
            
            isgo = @"0";
            
            break;
            
        }else if ([title isEqualToString:@"所属部门"] && SafeString(self.companyName.stringValue).length < 1&& [type isEqualToString:@"2"]){
            
            [self show:@"提示" andMessage:@"请选择部门"];
            
            isgo = @"0";
            
            break;
            
        }else if ([title isEqualToString:@"设备位置"] && SafeString(self.computerAddress.stringValue).length < 1 && [type isEqualToString:@"2"]){
            
            [self show:@"提示" andMessage:@"请输入设备位置"];
            
            isgo = @"0";
            
            break;
            
        }else if ([title isEqualToString:@"联系电话"] && SafeString(self.phoneNum.stringValue).length < 1&& [type isEqualToString:@"2"]){
            
            [self show:@"提示" andMessage:@"请输入联系电话"];
            
            isgo = @"0";
            
            break;
            
        }else if ([title isEqualToString:@"电子邮箱"]){
            
            if(SafeString(self.mail.stringValue).length < 1 && [type isEqualToString:@"2"]){
                
                [self show:@"提示" andMessage:@"请输入电子邮箱"];
                
                isgo = @"0";
   
                break;

            }else if (SafeString(self.mail.stringValue).length > 1){

                BOOL isemail = [JumpPublicAction isEmailAdress:self.mail.stringValue];
                
                if(isemail){
                    
                    isgo = @"1";

                    continue;
                    
                }else{
                    
                    [self show:@"提示" andMessage:@"邮箱格式有误"];
                    
                    isgo = @"0";
                    
                    break;

                }
            }
            
        }else if ([title isEqualToString:@"设备类型"] && SafeString(self.deviceType.stringValue).length < 1 && [type isEqualToString:@"2"]){
            
            [self show:@"提示" andMessage:@"请输入设备类型"];
            
            isgo = @"0";
            
            break;
            
        }else if ([title isEqualToString:@"备注"]){
            
            if(SafeString(self.remark.stringValue).length < 1 && [type isEqualToString:@"2"]){
                
                [self show:@"提示" andMessage:@"请输入备注"];
                
                isgo = @"0";
                
                break;

            }else if (SafeString(self.remark.stringValue).length > 101){
                
                [self show:@"提示" andMessage:@"备注长度最多100个字符"];
                
                isgo = @"0";
                
                break;

            }else{
                
                isgo = @"1";
                
                continue;

            }
        }
    }
    
    if([isgo isEqualToString:@"1"]){
        
        [self registerAction];
    }
    
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




-(void)registerAction{
    
    L2CWeakSelf(self);
    
    //获取本机的ip地址
    NSString *macIp = [JumpPublicAction getDeviceIPAddress];
    NSString *macAddress = [JumpPublicAction getDeviceMacAddress];

    NSDictionary *defaultDict = [JumpKeyChain getKeychainDataForKey:@"userInfo"];

    NSString *deviceCode = SafeString(defaultDict[@"deviceId"]);
    NSString *port = SafeString(defaultDict[@"port"]);
    NSString *ipAddress = SafeString(defaultDict[@"ipAddress"]);
    NSString *userId = SafeString(defaultDict[@"userId"]);

    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    
    paramters[@"userId"] = userId;
    paramters[@"name"] = SafeString(self.userName.stringValue);
    paramters[@"departmentName"] = SafeString(self.dataDict[@"companyName"]);
    paramters[@"departmentId"] = SafeString(self.dataDict[@"companyId"]);
    paramters[@"address"] = SafeString(self.computerAddress.stringValue);
    paramters[@"phoneNumber"] = SafeString(self.phoneNum.stringValue);
    paramters[@"email"] = SafeString(self.mail.stringValue);
    paramters[@"deviceType"] = @"3";
    paramters[@"remark"] = SafeString(self.remark.stringValue);
    paramters[@"sid"] = SafeString(deviceCode);
    paramters[@"ip"] = SafeString(macIp);
    paramters[@"mac"] = SafeString(macAddress);
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",ipAddress,port,Mac_Register];
    
    [AFNHelper macPost:urlStr parameters:paramters success:^(id responseObject) {
        
        if([responseObject[@"message"] isEqualToString:@"ok"]){
            
           
            [weakself show:@"提示" andMessage:@"保存成功"];
            
            [weakself userInfoDetail];

        }else{
            
            [weakself show:@"提示" andMessage:@"保存失败"];
            
        }
        
    } andFailed:^(id error) {
        
        [weakself show:@"提示" andMessage:@"保存失败"];
    }];
}

#pragma mark --- 获取注册列表

-(void)getTitleNameArray{
    
    L2CWeakSelf(self);
    
    NSDictionary *defaultDict = [JumpKeyChain getKeychainDataForKey:@"userInfo"];
    
    NSString *port = SafeString(defaultDict[@"port"]);
    NSString *ipAddress = SafeString(defaultDict[@"ipAddress"]);
    NSString *userId = SafeString(defaultDict[@"userId"]);

    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",ipAddress,port,Mac_RegInfoName];
    
    [AFNHelper macPost:urlStr parameters:@{@"userId":userId} success:^(id responseObject) {
        
        if([SafeString(responseObject[@"message"]) isEqualToString:@"ok"]){
            
            self.titleArray = [NSMutableArray array];
            
            self.titleArray = responseObject[@"result"];
            
            [weakself settingDefaultUI];//判断是否可以输入
            
            [weakself userInfoDetail];//获取详情
            
        }else{
            
            [weakself show:@"提示" andMessage:@"获取服务器配置失败"];
        }
        
    } andFailed:^(id error) {
        
        [weakself show:@"提示" andMessage:@"服务器请求失败"];

    }];
}

//设置默认。隐藏时不让输入
-(void)settingDefaultUI{
    
    for (NSDictionary *titleDict in self.titleArray) {
        
        NSString *title = SafeString(titleDict[@"title"]);
        NSString *type = SafeString(titleDict[@"type"]);
        NSString *defaultContent = SafeString(titleDict[@"default_item"]);
        NSString *discripe = SafeString(titleDict[@"discripe"]);

        if([title isEqualToString:@"使用人"]){
            
            if([type isEqualToString:@"0"]){
                
                self.userName.enabled = NO;

            }else{

                self.userName.enabled = YES;
            }
            
            if(defaultContent.length > 0){
                
                self.userName.placeholderString = defaultContent;
                
            }else{
                
                self.userName.placeholderString = discripe;
            }
            
        }else if ([title isEqualToString:@"所属部门"]){
            
            if([type isEqualToString:@"0"]){
                
                self.chooseDepart.enabled = NO;
                
            }else{
                
                self.chooseDepart.enabled = YES;
            }
            
            if(defaultContent.length > 0){
                
                self.companyName.placeholderString = defaultContent;
                
            }else{
                
                self.companyName.placeholderString = discripe;
            }
            
        }else if ([title isEqualToString:@"设备位置"]){
            
            if([type isEqualToString:@"0"]){
                
                self.computerAddress.enabled = NO;
                
            }else{
                
                self.computerAddress.enabled = YES;
            }
            
            if(defaultContent.length > 0){
                
                self.computerAddress.placeholderString = defaultContent;
                
            }else{
                
                self.computerAddress.placeholderString = discripe;
            }
            
        }else if ([title isEqualToString:@"联系电话"]){
            
            if([type isEqualToString:@"0"]){
                
                self.phoneNum.enabled = NO;
                
            }else{
                
                self.phoneNum.enabled = YES;
            }
            
            if(defaultContent.length > 0){
                
                self.phoneNum.placeholderString = defaultContent;
                
            }else{
                
                self.phoneNum.placeholderString = discripe;
            }

        }else if ([title isEqualToString:@"电子邮箱"]){
            
            if([type isEqualToString:@"0"]){
                
                self.mail.enabled = NO;
                
            }else{
                
                self.mail.enabled = YES;
            }
            
            if(defaultContent.length > 0){
                
                self.mail.placeholderString = defaultContent;
                
            }else{
                
                self.mail.placeholderString = discripe;
            }
            
        }else if ([title isEqualToString:@"设备类型"]){
 
            self.deviceType.enabled = NO;
           
            self.deviceType.stringValue = @"MacOS";
            
        }else if ([title isEqualToString:@"备注"]){
            
            if([type isEqualToString:@"0"]){
                
                self.remark.enabled = NO;
                
            }else{
                
                self.remark.enabled = YES;
            }
            
            if(defaultContent.length > 0){
                
                self.remark.placeholderString = defaultContent;
                
            }else{
                
                self.remark.placeholderString = discripe;
            }
        }
    }
}

#pragma mark --- 获取个人信息

-(void)userInfoDetail{
    
    L2CWeakSelf(self);
    
    NSDictionary *defaultDict = [JumpKeyChain getKeychainDataForKey:@"userInfo"];
    
    NSString *port = SafeString(defaultDict[@"port"]);
    NSString *ipAddress = SafeString(defaultDict[@"ipAddress"]);
    NSString *userId = SafeString(defaultDict[@"userId"]);
    NSString *deviceCode = SafeString(defaultDict[@"deviceId"]);

    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",ipAddress,port,Mac_GetUserInfo];
    
    NSString *macIp = [JumpPublicAction getDeviceIPAddress];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"userId"] = userId;
    parameters[@"sid"] = SafeString(deviceCode);
    parameters[@"ip"] = macIp;
    
    [AFNHelper macPost:urlStr parameters:parameters success:^(id responseObject) {
        
        if([responseObject[@"message"] isEqualToString:@"ok"]){
            
            //使用人
            weakself.userName.stringValue = SafeString(responseObject[@"result"][@"name"]);
            //电子邮箱
            weakself.mail.stringValue = SafeString(responseObject[@"result"][@"email"]);
            //设备类型
            weakself.deviceType.stringValue = @"MacOS";
            //电话
            weakself.phoneNum.stringValue = SafeString(responseObject[@"result"][@"phoneNumber"]);
            //设备位置
            weakself.computerAddress.stringValue = SafeString(responseObject[@"result"][@"address"]);
            //部门名称
            weakself.companyName.stringValue = SafeString(responseObject[@"result"][@"departmentName"]);
            //备注
            weakself.remark.stringValue = SafeString(responseObject[@"result"][@"remark"]);
            
            weakself.dataDict[@"companyName"] = SafeString(responseObject[@"result"][@"departmentName"]);
            //部门id
            weakself.dataDict[@"companyId"] = SafeString(responseObject[@"result"][@"departmentId"]);

            weakself.accout = SafeString(responseObject[@"result"][@"account"]);
            
        }else{
            
            [weakself show:@"提示" andMessage:@"获取设备信息失败"];
        }
        
    } andFailed:^(id error) {
        
        [weakself show:@"提示" andMessage:@"请求服务器失败"];
        
    }];
}

#pragma mark --- 提示框

-(void)show:(NSString *)title andMessage:(NSString *)message{
    
    NSAlert *alert = [[NSAlert alloc]init];
    
    alert.messageText = title;
    
    alert.informativeText = message;
    
    //设置提示框的样式
    alert.alertStyle = NSAlertStyleWarning;
    
    [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
}


@end
