//
//  JumpRegistereWindowController.m
//  MacOSJump
//
//  Created by jumpapp1 on 2019/4/3.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "JumpRegistereWindowController.h"
#import "ChooseConmpanyWindowController.h"
#import "AppDelegate.h"
#import "FirstPageTabController.h"
#import "FirstPageTabController.h"
//wifi信息
#import <sys/socket.h>
#import <ifaddrs.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>

@interface JumpRegistereWindowController ()<ChooseCompanyDelegate>

@property (strong,nonatomic) FirstPageTabController *firstPageWC;

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
//mac地址
@property (copy,nonatomic) NSString *macAddress;

@end

@implementation JumpRegistereWindowController


-(NSMutableDictionary *)dataDict{
    
    if(!_dataDict){
        
        _dataDict = [NSMutableDictionary dictionary];
    }
    
    return _dataDict;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.choosePeople = [[ChooseConmpanyWindowController alloc]initWithWindowNibName:@"ChooseConmpanyWindowController"];
    
    self.firstPageWC = [[FirstPageTabController alloc]initWithWindowNibName:@"FirstPageTabController"];
    
    self.choosePeople.delegate = self;
    
    [self getMacaddress];
    
    [self getTitleNameArray];//获取注册列表
}


#pragma mark --- 保存

- (IBAction)saveAction:(NSButton *)sender {
    
    NSString *isgo = @"1";
    
    for (NSDictionary *titleDict in self.titleArray) {
        
        NSString *title = SafeString(titleDict[@"title"]);
        NSString *type = SafeString(titleDict[@"type"]);
        
        if([title isEqualToString:@"使用人"] && self.userName.stringValue.length < 1 && [type isEqualToString:@"1"]){
            
            [self show:@"提示" andMessage:@"请输入使用人"];
            
            isgo = @"0";
            
            break;
            
        }else if ([title isEqualToString:@"所属部门"] && self.companyName.stringValue.length < 1&& [type isEqualToString:@"1"]){
            
            [self show:@"提示" andMessage:@"请选择部门"];
            
            isgo = @"0";
            
            break;
            
        }else if ([title isEqualToString:@"设备位置"] && self.computerAddress.stringValue.length < 1&& [type isEqualToString:@"1"]){
            
            [self show:@"提示" andMessage:@"请输入设备位置"];
            
            isgo = @"0";
            
            break;
            
        }else if ([title isEqualToString:@"联系电话"] && self.phoneNum.stringValue.length < 1&& [type isEqualToString:@"1"]){
            
            [self show:@"提示" andMessage:@"请输入联系电话"];
            
            isgo = @"0";
            
            break;
            
        }else if ([title isEqualToString:@"电子邮箱"] && self.mail.stringValue.length < 1 && [type isEqualToString:@"1"]){
            
            [self show:@"提示" andMessage:@"请输入电子邮箱"];
            
            isgo = @"0";
            
            break;
            
        }else if ([title isEqualToString:@"设备类型"] && self.deviceType.stringValue.length < 1 && [type isEqualToString:@"1"]){
            
            [self show:@"提示" andMessage:@"请输入设备类型"];
            
            isgo = @"0";
            
            break;
            
        }else if ([title isEqualToString:@"备注"] && self.remark.stringValue.length < 1 && [type isEqualToString:@"1"]){
            
            [self show:@"提示" andMessage:@"请输入备注"];
            
            isgo = @"0";
            
            break;
            
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
    NSString *macIp = [self getDeviceIPAddress];
    
    NSDictionary *defaultDict = [JumpKeyChain getKeychainDataForKey:@"userInfo"];
    
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
    paramters[@"sid"] = SafeString(self.deviceCode);
    paramters[@"ip"] = SafeString(macIp);
    paramters[@"mac"] = SafeString(self.macAddress);

    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",ipAddress,port,Mac_Register];
    
    [AFNHelper macPost:urlStr parameters:paramters success:^(id responseObject) {
        
        if([responseObject[@"message"] isEqualToString:@"ok"]){
            
                [weakself.firstPageWC.window orderFront:nil];//显示要跳转的窗口
                
                [[weakself.firstPageWC window] center];//显示在屏幕中间
                
                [weakself.window orderOut:nil];//关闭当前窗口
         
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
            
            if([type isEqualToString:@"0"]){
                
                self.deviceType.enabled = NO;
                
            }else{
                
                self.deviceType.enabled = YES;
            }
            
            self.deviceType.stringValue = @"Mac";
            
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


#pragma mark --- 提示框

-(void)show:(NSString *)title andMessage:(NSString *)message{
    
    NSAlert *alert = [[NSAlert alloc]init];
    
    alert.messageText = title;
    
    alert.informativeText = message;
    
    //设置提示框的样式
    alert.alertStyle = NSAlertStyleWarning;
    
    [alert beginSheetModalForWindow:self.window completionHandler:nil];
}


#pragma mark -- 获取本机IP地址和Mac地址

- (NSString *)getDeviceIPAddress {
    
    NSString *address = @"";
    
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    struct sockaddr_in *sockaddr = (struct sockaddr_in *)temp_addr->ifa_addr;
                    address = [NSString stringWithUTF8String:inet_ntoa(sockaddr->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    NSLog(@"IP地址是：%@", address);
    return address;
}


- (void)getMacaddress
{
    kern_return_t kr;
    CFMutableDictionaryRef matchDict;
    io_iterator_t iterator;
    io_registry_entry_t entry;
    
    matchDict = IOServiceMatching("IOEthernetInterface");
    kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matchDict, &iterator);
    
    NSDictionary *resultInfo = nil;
    
    while ((entry = IOIteratorNext(iterator)) != 0)
    {
        CFMutableDictionaryRef properties=NULL;
        kr = IORegistryEntryCreateCFProperties(entry,
                                               &properties,
                                               kCFAllocatorDefault,
                                               kNilOptions);
        if (properties)
        {
            resultInfo = (__bridge_transfer NSDictionary *)properties;
            NSString *bsdName = [resultInfo objectForKey:@"BSD Name"];
            NSData *macData = [resultInfo objectForKey:@"IOMACAddress"];
            if (!macData)
            {
                continue;
            }
            
            NSMutableString *macAddress = [[NSMutableString alloc] init];
            const UInt8 *bytes = [macData bytes];
            for (int i=0; i<macData.length; i++)
            {
                [macAddress appendFormat:@"%02x",*(bytes+i)];
            }
            
//            打印Mac地址
            if (bsdName && macAddress)
            {
                NSLog(@"网卡:%@\nMac地址:%@\n",bsdName,macAddress);
            }
            
            self.macAddress = [NSString stringWithFormat:@"%@",macAddress];
            
        }
    }
    
    IOObjectRelease(iterator);
}


@end
