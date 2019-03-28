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


@interface MainWindowController ()

@property (strong,nonatomic) FirstPageTabController *firstPageWC;

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
//注册按钮
@property (weak) IBOutlet NSButton *registerBtn;
//登录按钮
@property (weak) IBOutlet NSButton *loginBtn;
//距离右侧距离  验证码98  账号20
@property (weak) IBOutlet NSLayoutConstraint *rightDistance;

@property (strong,nonatomic) NSTimer *timer;

@property (assign,nonatomic) NSInteger timerNum;

@end

@implementation MainWindowController


- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.contentViewController.view.wantsLayer = YES;
    
    self.getCodeBtn.hidden = YES;
    
    self.contentViewController.view.layer.backgroundColor = [NSColor magentaColor].CGColor;

    self.firstPageWC = [[FirstPageTabController alloc]initWithWindowNibName:@"FirstPageTabController"];

    [self.window setContentSize:NSMakeSize(800, 600)];
    
    self.window.restorable = NO;
    
    [self defaultShow];
    
    [self getLoginType];
    
}

-(void)defaultShow{

    NSDictionary *defaultDict = [JumpKeyChain getKeychainDataForKey:@"userInfo"];
    
    self.accountcontent.stringValue = SafeString(defaultDict[@"userName"]);
    self.portcontent.stringValue = SafeString(defaultDict[@"port"]);
    self.ipcontent.stringValue = SafeString(defaultDict[@"ipAddress"]);
    self.codecontent.stringValue = SafeString(defaultDict[@"password"]);


}


#pragma mark --- 登录

- (IBAction)LoginAction:(NSButton *)sender {
    
    if(self.accountcontent.stringValue.length < 1 || self.codecontent.stringValue.length < 1 || self.ipcontent.stringValue.length < 1 || self.portcontent.stringValue.length < 1){
        
        [self show:@"提示" andMessage:@"必填字段不能为空"];

        return;
    }
 
    [self loginAction];

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
    
    [self sendCode];//获取验证码
    
    self.getCodeBtn.enabled = NO;
    
    self.timerNum = 60;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f  //间隔时间
                                                  target:self
                                                selector:@selector(countdown)
                                                userInfo:nil
                                                 repeats:YES];
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

-(void)loginAction{
    
    L2CWeakSelf(self);
    
    [self loadAnimat];
    
    NSString *loginType = @"";
    
    if([self.passwordTitle.stringValue isEqualToString:@"账号密码登录"]){
        
        loginType = @"1";
        
    }else{
        
        loginType = @"1";
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
            
            //登录成功后 ---- 用户名,密码,设备唯一识别号进行保存(在用户名和密码登录的时候才进行保存)
            
            if([loginType isEqualToString:@"1"]){
                
                NSDictionary *dict = @{@"userName":self.accountcontent.stringValue,@"password":self.codecontent.stringValue,@"deviceId":@"",@"ipAddress":self.ipcontent.stringValue,@"port":self.portcontent.stringValue,@"userId":userId};
                
                [JumpKeyChain addKeychainData:dict forKey:@"userInfo"];
                
            }

            [weakself.firstPageWC.window orderFront:nil];//显示要跳转的窗口
            
            [[weakself.firstPageWC window] center];//显示在屏幕中间
            
            [weakself.window orderOut:nil];//关闭当前窗口
            
        }else{
            
            JumpLog(@"登录失败");
            [weakself show:@"提示" andMessage:@"登录失败"];
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
    
    [alert beginSheetModalForWindow:self.window completionHandler:nil];
}

#pragma mark --- 加载动画

-(void)loadAnimat{
    
//    [NSAnimationContext beginGrouping];
//    [[NSAnimationContext currentContext]setDuration:3.0f]; //执行时间
//    [[self.window.contentView animator]setAlphaValue:0.1f]; //改变属性值  此项是设置透明度
  
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
        
        if([responseObject[@"message"] isEqualToString:@"ok"]){
            
            NSString *smscertType = SafeString(responseObject[@"result"][@"smscert"]);
            NSString *codeType = SafeString(responseObject[@"result"][@"accountcert"]);
            
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
                
                title = @"用户名密码登录";
            }
            
        }else{
            
            type = @"3";
            
            title = @"用户名密码登录";
            
        }
        
        [weakself defaultUI:title andType:type];
        
    } andFailed:^(id error) {
        
        [weakself defaultUI:@"用户名密码登录" andType:@"3"];

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


@end
