//
//  JumpStatusViewController.m
//  MacOSJump
//
//  Created by jumpapp1 on 2019/3/19.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "JumpStatusViewController.h"
#import "MainWindowController.h"


@interface JumpStatusViewController ()

//状态
@property (weak) IBOutlet NSTextField *status;
//时间
@property (weak) IBOutlet NSTextField *time;
//时长
@property (weak) IBOutlet NSTextField *longtime;
//状态图片
@property (weak) IBOutlet NSImageView *statusImage;

@property (strong ,nonatomic) NSTimer *connectTimer;

@property(assign,nonatomic) BOOL isClick;

@property (strong, nonatomic) MainWindowController *mainWc;

@end

@implementation JumpStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isClick = NO;
    
    self.mainWc = [[MainWindowController alloc]initWithWindowNibName:@"MainWindowController"];

    [self creatInfo];
}

//刷新方法
- (IBAction)clickRefresh:(NSButton *)sender {
    
    self.isClick = YES;
    
    [self creatInfo];
}



-(void)creatInfo{
    
    L2CWeakSelf(self);
    
    NSDictionary *defaultDict = [JumpKeyChain getKeychainDataForKey:@"userInfo"];
    
    NSString *port = SafeString(defaultDict[@"port"]);
    NSString *ipAddress = SafeString(defaultDict[@"ipAddress"]);
    NSString *userId = SafeString(defaultDict[@"userId"]);
    NSString *deviceCode = SafeString(defaultDict[@"deviceId"]);
    NSString *macIp = [JumpPublicAction getDeviceIPAddress];

    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",ipAddress,port,Mac_GetUserInfo];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"userId"] = userId;
    parameters[@"sid"] = deviceCode;
    parameters[@"ip"] = macIp;

    [AFNHelper macPost:urlStr parameters:parameters success:^(id responseObject) {
        
        if([responseObject[@"message"] isEqualToString:@"ok"]){
            
            if(weakself.isClick == NO){
                
                [weakself timeStart]; //启动心跳
            }
            
            if([SafeString(responseObject[@"result"][@"deviceStatus"]) isEqualToString:@"1"]){
                
                weakself.statusImage.image = [NSImage imageNamed:@"bg-state-Y"];
                weakself.status.stringValue = @"在线";
                
            }else{
                
                weakself.statusImage.image = [NSImage imageNamed:@"bg-state-N"];
                weakself.status.stringValue = @"离线";
                
            }
            
            weakself.time.stringValue = SafeString(responseObject[@"result"][@"sureTime"]);
            weakself.longtime.stringValue = SafeString(responseObject[@"result"][@"surelength"]);
            
            if(weakself.isClick){
                
                [weakself show:@"提示" andMessage:@"刷新成功"];
            }
            
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



-(void)timeStart{
    
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f  //间隔时间
                                                         target:self
                                                       selector:@selector(longConnect)
                                                       userInfo:nil
                                                        repeats:YES];
}



-(void)longConnect{
    
    L2CWeakSelf(self);
    
    NSDictionary *defaultDict = [JumpKeyChain getKeychainDataForKey:@"userInfo"];
    
    NSString *port = SafeString(defaultDict[@"port"]);
    NSString *ipAddress = SafeString(defaultDict[@"ipAddress"]);
    NSString *deviceCode = SafeString(defaultDict[@"deviceId"]);
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",ipAddress,port,Mac_DeviceisOnline];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"sid"] = deviceCode;
    
    [AFNHelper macPost:urlStr parameters:parameters success:^(id responseObject) {
        
        if([responseObject[@"message"] isEqualToString:@"ok"]){
            
            if(![SafeString(responseObject[@"result"][@"isonline"]) isEqualToString:@"1"]){
                
                [weakself offlineAlert];
            }
           
        }else{
            
            [weakself offlineAlert];
        }
        
    } andFailed:^(id error) {
        
        JumpLog(@"连接服务器失败");
        
    }];
}


-(void)offlineAlert{
    
    [self.connectTimer invalidate];
    
    self.connectTimer = nil;
    
    NSAlert *alert = [[NSAlert alloc]init];
    
    alert.messageText = @"提示";
    
    alert.informativeText = @"该设备已下线";
    
    //设置提示框的样式
    alert.alertStyle = NSAlertStyleWarning;
    
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
       
        [self.mainWc.window orderFront:nil];//显示要跳转的窗口
        
        [[self.mainWc window] center];//显示在屏幕中间
        
        [self.tabwindow orderOut:nil];//关闭当前窗口
        
    }];
}

@end
