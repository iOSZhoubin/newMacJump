//
//  MainWindowController.m
//  MacOSJump
//
//  Created by jumpapp1 on 2019/1/14.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "MainWindowController.h"
#import "AppDelegate.h"
#import "FirstPageTabController.h"
#import "JumpRegistereWindowController.h"


@interface MainWindowController ()

@property (strong,nonatomic) FirstPageTabController *firstPageWC;

@property (strong,nonatomic) JumpRegistereWindowController *registereWC;

//ip地址
@property (weak) IBOutlet NSTextField *ipcontent;
//端口
@property (weak) IBOutlet NSTextField *portcontent;
//账号
@property (weak) IBOutlet NSTextField *accountcontent;
//密码or验证码的title
@property (weak) IBOutlet NSTextField *passwordTitle;
//密码or验证码
@property (weak) IBOutlet NSTextField *codecontent;
//获取验证码
@property (weak) IBOutlet NSButton *getCodeBtn;
//切换登录方式
@property (weak) IBOutlet NSButton *changeTypeBtn;
//登录按钮
@property (weak) IBOutlet NSButton *loginBtn;
//距离右侧距离  验证码98  账号20
@property (weak) IBOutlet NSLayoutConstraint *rightDistance;

@property (strong,nonatomic) NSTimer *timer;

@property (assign,nonatomic) NSInteger timerNum;

//设备唯一识别码
@property (copy,nonatomic) NSString *deviceCode;

@property (assign,nonatomic) BOOL isgetServer;

//是否为网内手机才可以登录
@property (copy,nonatomic) NSString *isIn;
//是否将手机号同步到设备联系电话
@property (copy,nonatomic) NSString *isSyn;
//登录界面是否自动填充手机号
@property (copy,nonatomic) NSString *isPut;


@end

@implementation MainWindowController


- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.contentViewController.view.wantsLayer = YES;
    
    self.getCodeBtn.hidden = YES;
    
    self.contentViewController.view.layer.backgroundColor = [NSColor magentaColor].CGColor;

    self.firstPageWC = [[FirstPageTabController alloc]initWithWindowNibName:@"FirstPageTabController"];

    self.registereWC = [[JumpRegistereWindowController alloc]initWithWindowNibName:@"JumpRegistereWindowController"];

    
    [self.window setContentSize:NSMakeSize(800, 600)];
    
    self.window.restorable = NO;
    
    self.isgetServer = NO;
    
    [self defaultShow];
    
    [self getLoginType];
    
}

-(void)defaultShow{

    NSDictionary *defaultDict = [JumpKeyChain getKeychainDataForKey:@"userInfo"];
    
    self.accountcontent.stringValue = SafeString(defaultDict[@"userName"]);
    self.portcontent.stringValue = SafeString(defaultDict[@"port"]);
    self.ipcontent.stringValue = SafeString(defaultDict[@"ipAddress"]);
    self.codecontent.stringValue = SafeString(defaultDict[@"password"]);
    
    self.deviceCode = [JumpKeyChain firstGetUUIDInKeychain];

}


#pragma mark --- 登录

- (IBAction)LoginAction:(NSButton *)sender {
    
    if (self.isgetServer == NO){
        
        [self show:@"提示" andMessage:@"请先获取服务器配置"];
        
        return;
   
    }else if(self.accountcontent.stringValue.length < 1 || self.codecontent.stringValue.length < 1 || self.ipcontent.stringValue.length < 1 || self.portcontent.stringValue.length < 1){
        
        [self show:@"提示" andMessage:@"必填字段不能为空"];

        return;
    
    }
    
    if(self.isgetServer == YES){
        
        [self clicklogin];
    }
  
}


-(void)clicklogin{
    
    L2CWeakSelf(self);
    
    NSString *loginType = @"";
    
    if([self.passwordTitle.stringValue isEqualToString:@"密码"]){
        
        loginType = @"1";
        
    }else{
        
        loginType = @"2";
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"account"] = SafeString(self.accountcontent.stringValue);
    parameters[@"loginType"] = SafeString(loginType);
    
    //登录方式 1-账号密码登录  2-验证码登录
    if([loginType isEqualToString:@"1"]){
        
        parameters[@"password"] = SafeString(self.codecontent.stringValue);
        
    }else{
        
        parameters[@"code"] = SafeString(self.codecontent.stringValue);
    }
    
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",self.ipcontent.stringValue,self.portcontent.stringValue,Mac_Login];
    
    [AFNHelper macPost:urlStr parameters:parameters success:^(id responseObject) {
        
        if([responseObject[@"message"] isEqualToString:@"ok"]){
            
            NSString *userId = SafeString(responseObject[@"result"][@"userId"]);

            if(weakself.deviceCode.length > 0){
            
                [weakself.firstPageWC.window orderFront:nil];//显示要跳转的窗口
                
                [[weakself.firstPageWC window] center];//显示在屏幕中间
                
                [weakself.window orderOut:nil];//关闭当前窗口
                
            }else{

                weakself.deviceCode = [JumpKeyChain getUUIDInKeychain];

                weakself.registereWC.deviceCode = weakself.deviceCode;

                [weakself.registereWC.window orderFront:nil];//显示要跳转的窗口

                [[weakself.registereWC window] center];//显示在屏幕中间

                [weakself.window orderOut:nil];//关闭当前窗口
            }
            
            //登录成功后 ---- 用户名,密码,设备唯一识别号进行保存(在用户名和密码登录的时候才进行保存)
            
            if([loginType isEqualToString:@"1"]){
                
                NSDictionary *dict = @{@"userName":self.accountcontent.stringValue,@"password":@"",@"deviceId":weakself.deviceCode,@"ipAddress":self.ipcontent.stringValue,@"port":self.portcontent.stringValue,@"userId":userId};
                
                [JumpKeyChain addKeychainData:dict forKey:@"userInfo"];
                
            }else{
                
                NSString *accountStr = @"";

                if([weakself.isPut isEqualToString:@"1"]){

                    accountStr = SafeString(self.accountcontent.stringValue);
                }

                NSDictionary *dict = @{@"userName":accountStr,@"password":@"",@"deviceId":SafeString(weakself.deviceCode),@"userId":SafeString(userId)};

                [JumpKeyChain addKeychainData:dict forKey:@"userInfo"];
                
            }
  
            
            if([weakself.isSyn isEqualToString:@"1"] && [weakself.passwordTitle.stringValue isEqualToString:@"验证码"]){
                //服务器勾选了将手机号同步到设备联系电话
                
                [self synWithPhone];
            }
        
        }else{
            
            JumpLog(@"登录失败");
            [weakself show:@"提示" andMessage:@"登录失败"];
        }
        
    } andFailed:^(id error) {
        
        [weakself show:@"提示" andMessage:@"请求服务器失败"];
        
    }];
}


#pragma mark --- 切换登录方式

- (IBAction)changeTypeAction:(NSButton *)sender {
    
    NSLog(@"切换登录方式");
    
    [self defaultUI:sender.title andType:nil];
}

#pragma mark --- 获取验证码

- (IBAction)getCodeAction:(NSButton *)sender {
    
    if(SafeString(self.accountcontent.stringValue).length < 1){

        [self show:@"提示" andMessage:@"手机号不能为空"];
        
        return;
    }

    BOOL isPhoneNum = [self validateCellPhoneNumber:SafeString(self.accountcontent.stringValue)];

    if(isPhoneNum == NO){

        [self show:@"提示" andMessage:@"手机号格式有误"];

        return;
    }
    
    if([self.isIn isEqualToString:@"1"]){//服务器勾选了只能网内手机获取验证码
        
        [self ischeck];
    
    }else{
        
        [self sendCode];//获取验证码
        
        self.getCodeBtn.enabled = NO;
        
        self.timerNum = 60;
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f  //间隔时间
                                                          target:self
                                                        selector:@selector(countdown)
                                                        userInfo:nil
                                                         repeats:YES];
    }
}


#pragma mark --- 校验手机号是否为内网号

-(void)ischeck{
    
    if(self.ipcontent.stringValue.length < 1){
        
        [self show:@"提示" andMessage:@"请填写ip地址"];
        
        return;
        
    }else if (self.portcontent.stringValue.length < 1){
        
        [self show:@"提示" andMessage:@"请填写端口号"];
        
        return;
    }
    
    L2CWeakSelf(self);
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",self.ipcontent.stringValue,self.portcontent.stringValue,Mac_IsIntranet];
    
    [AFNHelper macPost:urlStr parameters:@{@"phoneNumber":self.accountcontent.stringValue} success:^(id responseObject) {
       
        if([responseObject[@"message"] isEqualToString:@"ok"]){
            
            [weakself sendCode];//获取验证码
            
            weakself.getCodeBtn.enabled = NO;
            
            weakself.timerNum = 60;
            
            weakself.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f  //间隔时间
                                                          target:self
                                                        selector:@selector(countdown)
                                                        userInfo:nil
                                                         repeats:YES];
            
        }else{
            
            [weakself show:@"提示" andMessage:@"请联系管理员,目前只允许网内手机登录"];
            
            return;
            
        }
        
    } andFailed:^(id error) {
        
        [weakself show:@"提示" andMessage:@"请求服务器失败"];

    }];
}



- (void)countdown{
    
    self.timerNum --;
    
    if(self.timerNum < 0){
        
        [self.timer invalidate];
        
        self.timer = nil;
        
        self.timerNum = 0;
        
        self.getCodeBtn.enabled = YES;
        
        [self.getCodeBtn setTitle:@"获取验证码"];
        
    }else{
        
        [self.getCodeBtn setTitle:[NSString stringWithFormat:@"%ld秒",self.timerNum]];
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

#pragma mark --- 获取服务器配置的登录方式

-(void)getLoginType{
    
    L2CWeakSelf(self);
    
    if(self.ipcontent.stringValue.length < 1){
        
        return;
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",self.ipcontent.stringValue,self.portcontent.stringValue,Mac_GetloginType];
    
    [AFNHelper macPost:urlStr parameters:nil success:^(id responseObject) {
        
        NSString *type = @"3";
        NSString *title = @"用户名密码登录";

        if([weakself.passwordTitle.stringValue isEqualToString:@"验证码"]){
            
            title = @"短信验证码登录";
            
        }else{
            
            title = @"用户名密码登录";
            
        }
        
        if([responseObject[@"message"] isEqualToString:@"ok"]){
            
            NSString *smscertType = SafeString(responseObject[@"result"][@"smscert"]);
            NSString *codeType = SafeString(responseObject[@"result"][@"accountcert"]);
            
            weakself.isIn = SafeString(responseObject[@"result"][@"checknetphone"]);
            weakself.isSyn = SafeString(responseObject[@"result"][@"syncdevicephone"]);
            weakself.isPut = SafeString(responseObject[@"result"][@"filleddevicephone"]);

            
            if([smscertType isEqualToString:@"1"] && [codeType isEqualToString:@"0"]){
                //如果只支持短信验证码登录
                type = @"1";
                
                title = @"短信验证码登录";
                
            }else if ([smscertType isEqualToString:@"0"] && [codeType isEqualToString:@"1"]){
                //如果只支持账户密码登录
                type = @"2";
                
                title = @"用户名密码登录";
                
            }else{
                //两者都支持
                type = @"3";
                
                if([weakself.passwordTitle.stringValue isEqualToString:@"验证码"]){
                    
                    title = @"短信验证码登录";

                }else{
                    
                    title = @"用户名密码登录";
                    
                }
                
            }
            
            if(weakself.isgetServer == NO){
                
                [weakself show:@"提示" andMessage:@"获取服务器配置成功"];
            
            }else{
                
                [weakself show:@"提示" andMessage:@"获取服务器配置失败,请检查ip地址是否正确"];

            }
            
            weakself.isgetServer = YES;

        }else{
            
            type = @"3";
            
            if([weakself.passwordTitle.stringValue isEqualToString:@"验证码"]){
                
                title = @"短信验证码登录";
                
            }else{
                
                title = @"用户名密码登录";

            }
        }
        
        [weakself defaultUI:title andType:type];
        
    } andFailed:^(id error) {
        
        NSString *title;
        
        if([weakself.passwordTitle.stringValue isEqualToString:@"验证码"]){
            
            title = @"短信验证码登录";
            
        }else{
            
            title = @"用户名密码登录";
            
        }
        
        [weakself defaultUI:title andType:@"3"];
        
        [weakself show:@"提示" andMessage:@"获取服务器配置失败,请检查ip地址是否正确"];

    }];

}


-(void)defaultUI:(NSString *)title andType:(NSString *)type{
    
    if([title isEqualToString:@"用户名密码登录"]){
        
        [self.changeTypeBtn setTitle:@"短信验证码登录"];
        
        self.rightDistance.constant = 20;
        
        self.getCodeBtn.hidden = YES;
        
        self.codecontent.placeholderString = @"请输入密码(必填)";
        
        self.passwordTitle.stringValue = @"密码";
        
    }else{
        
        [self.changeTypeBtn setTitle:@"用户名密码登录"];
        
        self.rightDistance.constant = 110;
        
        self.getCodeBtn.hidden = NO;
        
        self.codecontent.placeholderString = @"请输入验证码(必填)";
        
        self.passwordTitle.stringValue = @"验证码";
        
    }
    
    if([type isEqualToString:@"1"] || [type isEqualToString:@"2"]){
        
        self.changeTypeBtn.hidden = YES;
        
    }else{
        
        self.changeTypeBtn.hidden = NO;
    }
    
}

#pragma mark --- 发送验证码

-(void)sendCode{
    
    L2CWeakSelf(self);
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",self.ipcontent.stringValue,self.portcontent.stringValue,Mac_CreatCode];
    
    [AFNHelper macPost:urlStr parameters:@{@"phoneNumber":SafeString(self.accountcontent.stringValue)} success:^(id responseObject) {
    
        if([SafeString(responseObject[@"message"]) isEqualToString:@"ok"]){
            
            [weakself show:@"提示" andMessage:@"验证码发送成功"];
            
        }else{
            
            [weakself show:@"提示" andMessage:@"验证码发送失败"];

        }
        
    } andFailed:^(id error) {
        
        [weakself show:@"提示" andMessage:@"请求服务器失败"];

    }];
    
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
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,175,176,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|7[56]|8[56])\\d{8}$";
    
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,177,180,189
     22         */
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


#pragma mark --- 获取服务器配置

- (IBAction)getServerSet:(NSButton *)sender {
    
    if(self.ipcontent.stringValue.length < 1){
        
        [self show:@"提示" andMessage:@"请填写ip地址"];
        
        return;
    
    }else if (self.portcontent.stringValue.length < 1){
        
        [self show:@"提示" andMessage:@"请填写端口号"];

        return;
    }
    
    self.isgetServer = NO;
    
    [self getLoginType];
}

#pragma mark --- 同步手机号到设备

-(void)synWithPhone{
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",self.ipcontent.stringValue,self.portcontent.stringValue,Mac_UpdataPhone];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"phoneNumber"] = self.accountcontent.stringValue;
    parameters[@"sid"] = self.deviceCode;

    [AFNHelper macPost:urlStr parameters:parameters success:^(id responseObject) {
        
        if([responseObject[@"message"] isEqualToString:@"ok"]){
            
            JumpLog(@"同步成功");
        }
        
    } andFailed:^(id error) {
        
    }];
}


@end
