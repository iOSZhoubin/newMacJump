//
//  JumploginRegistereViewController.m
//  MacOSJump
//
//  Created by jumpapp1 on 2019/4/17.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "JumploginRegistereViewController.h"
#import "ChooseConmpanyWindowController.h"
#import "AppDelegate.h"
#import "FirstPageViewController.h"
#import "FirstPageTabController.h"


@interface JumploginRegistereViewController ()<ChooseCompanyDelegate>

@property (strong,nonatomic) JumploginRegistereViewController *rgistereVC;

@property (strong,nonatomic) ChooseConmpanyWindowController *choosePeople;

@property (strong,nonatomic) FirstPageTabController *firstPageWC;

@property (strong,nonatomic) FirstPageViewController *checkVC;

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


//使用人title
@property (weak) IBOutlet NSTextField *userNameL;
//邮箱title
@property (weak) IBOutlet NSTextField *emailL;
//电话title
@property (weak) IBOutlet NSTextField *phoneL;
//位置title
@property (weak) IBOutlet NSTextField *addressL;
//部门title
@property (weak) IBOutlet NSTextField *deparmentL;
//备注title
@property (weak) IBOutlet NSTextField *remarkL;

@end

@implementation JumploginRegistereViewController

-(NSMutableDictionary *)dataDict{
    
    if(!_dataDict){
        
        _dataDict = [NSMutableDictionary dictionary];
    }
    
    return _dataDict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //加载对应的控制器
    self.checkVC = [[FirstPageViewController alloc]initWithNibName:@"FirstPageViewController" bundle:nil];
    
    self.choosePeople = [[ChooseConmpanyWindowController alloc]initWithWindowNibName:@"ChooseConmpanyWindowController"];
    
    self.firstPageWC = [[FirstPageTabController alloc]initWithWindowNibName:@"FirstPageTabController"];

    self.choosePeople.delegate = self;
    
    [self getTitleNameArray];//获取注册列表

}


#pragma mark --- 保存

- (IBAction)saveAction:(NSButton *)sender {
    
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
    
    if(SafeString(self.phoneNum.stringValue).length > 0){
        
        BOOL isPhone1 = [self validateCellPhoneNumber:self.phoneNum.stringValue];
        BOOL isPhone2 = [self isphone:self.phoneNum.stringValue];

        if(isPhone1 == NO && isPhone2 == NO){
            
            [self show:@"提示" andMessage:@"请输入正确的11位手机号码或座机号码(0298888888)"];
            
            return;
        }
    }
    
    if(SafeString(self.userName.stringValue).length > 0){
        
        BOOL isSpectil = [JumpPublicAction specialRight:SafeString(self.userName.stringValue)];
        
        if(isSpectil == NO){
            
            [self show:@"提示" andMessage:@"使用人中包含了特殊字符，请重新输入"];
            
            return;
            
        }
    }
    
    if(SafeString(self.userName.stringValue).length > 32){
        
        [self show:@"提示" andMessage:@"使用人最大为32字符"];
        
        return;
        
    }else if (SafeString(self.computerAddress.stringValue).length > 32){
        
        [self show:@"提示" andMessage:@"设备位置最长为32个字符"];
        
        return;
        
    }
    
    if([isgo isEqualToString:@"1"]){
        
        [self registerAction];
    }
}

#pragma mark --- 选择部门

- (IBAction)chooseAction:(NSButton *)sender {
    
    self.choosePeople.dict = self.redataDict;
    
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

    NSString *port = SafeString(self.redataDict[@"port"]);
    NSString *ipAddress = SafeString(self.redataDict[@"ipAddress"]);
    NSString *userId = SafeString(self.redataDict[@"userId"]);
    
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
    paramters[@"sid"] = SafeString(self.deviceCode);
    paramters[@"ip"] = SafeString(macIp);
    paramters[@"mac"] = SafeString(macAddress);
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",ipAddress,port,Mac_Register];
    
    [AFNHelper macPost:urlStr parameters:paramters success:^(id responseObject) {
        
        if([responseObject[@"message"] isEqualToString:@"ok"]){
            
            [JumpKeyChain addKeychainData:weakself.redataDict forKey:@"userInfo"];//保存用户名密码
                     
//            weakself.isCheck = @"0"; //强制不检查
                        
            if([weakself.isCheck isEqualToString:@"1"]){
                
                weakself.checkVC.dataDict = weakself.redataDict;
                
                weakself.checkVC.devnewId = weakself.deviceCode;
                
                weakself.checkVC.rewindow = weakself.rewindow;
                
                [weakself presentViewControllerAsSheet:weakself.checkVC];
                
            }else{
                
                [weakself.firstPageWC.window orderFront:nil];//显示要跳转的窗口
                
                [[weakself.firstPageWC window] center];//显示在屏幕中间
                
                [weakself.rewindow orderOut:nil];//关闭当前窗口
                
            }
 
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
    
    NSString *port = SafeString(self.redataDict[@"port"]);
    NSString *ipAddress = SafeString(self.redataDict[@"ipAddress"]);
    NSString *userId = SafeString(self.redataDict[@"userId"]);
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",ipAddress,port,Mac_RegInfoName];
    
    [AFNHelper macPost:urlStr parameters:@{@"userId":userId} success:^(id responseObject) {
        
        if([SafeString(responseObject[@"message"]) isEqualToString:@"ok"]){
            
            weakself.titleArray = [NSMutableArray array];
            
            weakself.titleArray = responseObject[@"result"];
            
            [weakself settingDefaultUI];//判断是否可以输入
            
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
                
                self.userNameL.textColor = [NSColor lightGrayColor];
                
            }else{
                
                self.userName.enabled = YES;
                
                self.userNameL.textColor = [NSColor blackColor];

            }
            
            if(defaultContent.length > 0){
                
                self.userName.placeholderString = defaultContent;
                
            }else{
                
                self.userName.placeholderString = discripe;
            }
            
        }else if ([title isEqualToString:@"所属部门"]){
            
            if([type isEqualToString:@"0"]){
                
                self.chooseDepart.enabled = NO;
                
                self.deparmentL.textColor = [NSColor lightGrayColor];

                
            }else{
                
                self.chooseDepart.enabled = YES;
                
                self.deparmentL.textColor = [NSColor blackColor];

            }
            
            if(defaultContent.length > 0){
                
                self.companyName.placeholderString = defaultContent;
                
            }else{
                
                self.companyName.placeholderString = discripe;
            }
            
        }else if ([title isEqualToString:@"设备位置"]){
            
            if([type isEqualToString:@"0"]){
                
                self.computerAddress.enabled = NO;
                
                self.addressL.textColor = [NSColor lightGrayColor];

                
            }else{
                
                self.computerAddress.enabled = YES;
                
                self.addressL.textColor = [NSColor blackColor];

            }
            
            if(defaultContent.length > 0){
                
                self.computerAddress.placeholderString = defaultContent;
                
            }else{
                
                self.computerAddress.placeholderString = discripe;
            }
            
        }else if ([title isEqualToString:@"联系电话"]){
            
            if([type isEqualToString:@"0"]){
                
                self.phoneNum.enabled = NO;
                
                self.phoneL.textColor = [NSColor lightGrayColor];

            }else{
                
                self.phoneNum.enabled = YES;
                
                self.phoneL.textColor = [NSColor blackColor];

            }
            
            if(defaultContent.length > 0){
                
                self.phoneNum.placeholderString = defaultContent;
                
            }else{
                
                self.phoneNum.placeholderString = discripe;
            }
            
        }else if ([title isEqualToString:@"电子邮箱"]){
            
            if([type isEqualToString:@"0"]){
                
                self.mail.enabled = NO;
                
                self.emailL.textColor = [NSColor lightGrayColor];

                
            }else{
                
                self.mail.enabled = YES;
                
                self.emailL.textColor = [NSColor blackColor];

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
                
                self.remark.textColor = [NSColor lightGrayColor];

                
            }else{
                
                self.remark.enabled = YES;
                
                self.remark.textColor = [NSColor blackColor];

            }
            
            if(defaultContent.length > 0){
                
                self.remark.placeholderString = defaultContent;
                
            }else{
                
                self.remark.placeholderString = discripe;
            }
        }
    }
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


#pragma mark --- 正则校验手机号码

-(BOOL)validateCellPhoneNumber:(NSString *)cellNum{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    /**
             * 中国移动：China Mobile
             * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
             */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    
    /**
             * 中国联通：China Unicom
             * 130,131,132,152,155,156,175,176,185,186
             */
    NSString * CU = @"^1(3[0-2]|5[256]|7[56]|8[56])\\d{8}$";
    
    /**
             * 中国电信：China Telecom
             * 133,1349,153,177,180,189
             */
    NSString * CT = @"^1((33|53|77|8[09])[0-9]|349)\\d{7}$";
    
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if(([regextestmobile evaluateWithObject:cellNum] == YES)
       || ([regextestcm evaluateWithObject:cellNum] == YES)
       || ([regextestct evaluateWithObject:cellNum] == YES)
       || ([regextestcu evaluateWithObject:cellNum] == YES)){
        return YES;
    }else{
        return NO;
    }
}


/**
 校验固话

 @param phoneNum 座机号码
 @return 是否通过
 */
-(BOOL)isphone:(NSString *)phoneNum{
    
    /**
     
     大陆地区固话及小灵通
     
     区号：010，020，021，022，023，024，025，027，028，029
     
     号码：7位或8位
     
     */
    
    NSString *phs = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";

    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phs];

    
    if([regextestphs evaluateWithObject:phoneNum] == YES){
       
        return YES;
        
    }else{
        
        return NO;
    }
}

@end
