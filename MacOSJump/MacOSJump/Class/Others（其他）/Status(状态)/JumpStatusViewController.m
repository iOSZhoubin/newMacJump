//
//  JumpStatusViewController.m
//  MacOSJump
//
//  Created by jumpapp1 on 2019/3/19.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "JumpStatusViewController.h"

@interface JumpStatusViewController ()

//状态
@property (weak) IBOutlet NSTextField *status;
//时间
@property (weak) IBOutlet NSTextField *time;
//时长
@property (weak) IBOutlet NSTextField *longtime;
//状态图片
@property (weak) IBOutlet NSImageView *statusImage;

@property(assign,nonatomic) BOOL isClick;

@end

@implementation JumpStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isClick = NO;
    
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

    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",ipAddress,port,Mac_GetUserInfo];
    
    
    [AFNHelper macPost:urlStr parameters:@{@"userId":userId} success:^(id responseObject) {
        
        if([responseObject[@"message"] isEqualToString:@"ok"]){
            
            if([SafeString(responseObject[@"result"][@"deviceStatus"]) isEqualToString:@"0"]){
                
                self.statusImage.image = [NSImage imageNamed:@"bg-state-N"];
                self.status.stringValue = @"正常";
                
            }else{
                
                self.statusImage.image = [NSImage imageNamed:@"bg-state-Y"];
                self.status.stringValue = @"不通过";
                
            }
            
            self.time.stringValue = SafeString(responseObject[@"result"][@"sureTime"]);
            self.longtime.stringValue = SafeString(responseObject[@"result"][@"surelength"]);
            
            if(self.isClick){
                
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


@end
