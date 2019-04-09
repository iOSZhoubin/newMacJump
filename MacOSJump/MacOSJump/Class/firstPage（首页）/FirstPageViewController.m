//
//  FirstPageViewController.m
//  MacOSJump
//
//  Created by jumpapp1 on 2019/3/19.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "FirstPageViewController.h"
#import "ApplicitionModel.h"
#import "DateCalculater.h"
#import <sys/socket.h>
#import <ifaddrs.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>

@interface FirstPageViewController ()

//检查项1
@property (weak) IBOutlet NSImageView *itemOne;
//检查项2
@property (weak) IBOutlet NSImageView *itemTwo;
//检查项3
@property (weak) IBOutlet NSImageView *itemThree;
//检查项4
@property (weak) IBOutlet NSImageView *itemFour;
//进度条
@property (weak) IBOutlet NSProgressIndicator *progress;
//检查内容
@property (weak) IBOutlet NSTextField *itemContent;
//重新检测按钮
@property (weak) IBOutlet NSButton *againBtn;
//定时器
@property (strong,nonatomic) NSTimer *timer;
//进程名称
@property (strong,nonatomic) NSMutableArray <ApplicitionModel *> *dataArray;

//允许进程安装检查Array
@property (strong,nonatomic) NSMutableArray *processY;
//禁止进程安装检查Array
@property (strong,nonatomic) NSMutableArray *processN;
//检查总Array
@property (strong,nonatomic) NSMutableArray *sumArray;
//服务器时间
@property (copy,nonatomic) NSString *serverTime;
//服务器ip地址
@property (copy,nonatomic) NSString *serverIp;
//进度条
@property (assign,nonatomic) NSInteger progressV;
//
@property (strong,nonatomic) NSMutableString *contentStr;
//
@property (assign,nonatomic) BOOL isTrue;
//
@property (assign,nonatomic) BOOL isRight;

@end

@implementation FirstPageViewController

-(NSMutableArray<ApplicitionModel *> *)dataArray{
    
    if(!_dataArray){
        
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getAllCheck];

    [self progressStatus];
}


-(void)progressStatus{
    
    L2CWeakSelf(self);
    
    self.progress.doubleValue = 0;
    
    self.itemContent.stringValue = @"";
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.25f repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        weakself.progressV = weakself.progress.doubleValue;
        
        if(weakself.progressV >= 100){
            
            weakself.progress.doubleValue = 100;
            
            [weakself.timer invalidate];
            
            weakself.timer = nil;
            
            self.againBtn.enabled = YES;
            
            self.itemContent.stringValue = self.contentStr;

            if(self.isRight==YES && self.isTrue==YES){

                [self saveData:@"1"];

            }else{

                [self saveData:@"0"];
            }
            
        }else{
            
            [weakself.progress incrementBy:1];
            
            self.itemContent.stringValue = @"正在检测...\n";
            
            self.againBtn.enabled = NO;
            
        }
        
    }];
}

#pragma mark --- 开始检测

- (IBAction)backAction:(NSButton *)sender {
    
    [self getAllCheck];
    
    [self progressStatus];
}




#pragma mark --- 获取检查项

-(void)getAllCheck{
    
    L2CWeakSelf(self);
    
    NSDictionary *defaultDict = [JumpKeyChain getKeychainDataForKey:@"userInfo"];
    
    NSString *port = SafeString(defaultDict[@"port"]);
    
    NSString *ipAddress = SafeString(defaultDict[@"ipAddress"]);
    
    NSString *userId = SafeString(defaultDict[@"userId"]);
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",ipAddress,port,Mac_CheckEntry];
    
    [AFNHelper macPost:urlStr parameters:@{@"userId":userId} success:^(id responseObject) {
        
        weakself.processY = [NSMutableArray array];
        weakself.processN = [NSMutableArray array];
        
        NSArray *dataArray = responseObject[@"result"];
        
        for (NSDictionary *dict in dataArray) {
            
            /**
             name:必须安装APP检查  type:mobilemustappcheck
             name:禁止安装APP检查  type:mobileprogibitedappcheck
             name:必须运行进程检查  type:mobilemustprocesscheck
             name:禁止运行进程检查  type:mobileprogibitedprocesscheck
             */
            
            NSString *type = dict[@"type"];
            
            NSString *jsonStr = dict[@"policy"];
            
            NSDictionary *dict = [jsonStr mj_JSONObject];
            
            NSArray *array = dict[@"content"];
            
            if ([type isEqualToString:@"mobilemustprocesscheck"]){
                
                [weakself.processY addObjectsFromArray:array];
                
            }else if ([type isEqualToString:@"mobileprogibitedprocesscheck"]){
                
                [weakself.processN addObjectsFromArray:array];

            }
        }

        [weakself getAppName];
        
    } andFailed:^(id error) {
        
    
    }];
}


#pragma mark --- 获取进程名称

-(void)getAppName{
    
    //获取正在运行的app名称
    NSArray<NSRunningApplication *> *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    
    for (NSRunningApplication *app in apps) {
        
        ApplicitionModel *model = [[ApplicitionModel alloc]initApplationModelName:app.localizedName bundleURL:app.bundleURL processIdentifier:app.processIdentifier launchDate:app.launchDate icon:app.icon];
        
        [self.dataArray addObject:model];
    }
    
    [self ishaveAppname];
 
}

//检查进程等
-(void)ishaveAppname{
    
    NSString *isNormal = @"1";
    NSString *isBan = @"1";
    
    for (ApplicitionModel *model in self.dataArray) {

        NSString *name = model.localizedName;

        for (NSInteger i=0; i<self.processN.count; i++) {

            NSString *proName = self.processN[i][@"processname"];

            if([name isEqualToString:proName]){

                isNormal = @"0";

                break;

            }else{

                isNormal = @"1";
            }
        }

        if([isNormal isEqualToString:@"0"]){

            break;
        }
    }
    
    for (ApplicitionModel *model in self.dataArray) {
        
        NSString *name = model.localizedName;
        
        for (NSInteger i=0; i<self.processY.count; i++) {
            
            NSString *proName = self.processY[i][@"processname"];
            
            if([name isEqualToString:proName]){
                
                isBan = @"1";
                
            }else{
                
                isBan = @"0";
                
                break;

            }
        }
        
        if([isBan isEqualToString:@"0"]){
            
            break;
        }
    }
    
    self.contentStr = [NSMutableString string];

    
    if([isNormal isEqualToString:@"0"]){
        
        [self.contentStr appendFormat:@"允许运行进程检查异常..."];

        
    }else if([isNormal isEqualToString:@"1"]){
        
        [self.contentStr appendFormat:@"允许运行进程检查正常..."];

    }
    
    
    if([isBan isEqualToString:@"1"]){

        [self.contentStr appendFormat:@"\n禁止运行进程检查异常..."];

    }else if([isBan isEqualToString:@"0"]){

        [self.contentStr appendFormat:@"\n禁止运行进程检查正常..."];

    }
    
    
    [self getServerInfo];
    
}



#pragma mark --- 获取服务器时间和IP地址

-(void)getServerInfo{
    
    L2CWeakSelf(self);
    
    NSDictionary *defaultDict = [JumpKeyChain getKeychainDataForKey:@"userInfo"];
    
    NSString *port = SafeString(defaultDict[@"port"]);
    
    NSString *ipAddress = SafeString(defaultDict[@"ipAddress"]);
    
    NSString *userId = SafeString(defaultDict[@"userId"]);
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",ipAddress,port,Mac_ServerInfo];
    
    [AFNHelper macPost:urlStr parameters:@{@"userId":userId} success:^(id responseObject) {
        
        if([responseObject[@"message"] isEqualToString:@"ok"]){
            
            NSDictionary *dict = responseObject[@"result"];
            
            weakself.serverTime = dict[@"serverTime"];//服务器时间
            
            weakself.serverIp = dict[@"serverIp"];//服务器ip地址
            
            [weakself compareIpandTime];

        }else{
            
        }
        
    } andFailed:^(id error) {
        
        
    }];
}

//比较ip地址与时间
-(void)compareIpandTime{
    
    //获取系统当前时间
    NSDate *datenow = [NSDate new];

    //时间转时间戳
    NSInteger nowNum = [[NSNumber numberWithDouble:[datenow timeIntervalSince1970]] integerValue];
    
    NSDate *serverDate = [DateCalculater dateAndTimeFromString:self.serverTime];
    
    NSInteger serverNum = [[NSNumber numberWithDouble:[serverDate timeIntervalSince1970]] integerValue];
    
    NSInteger reductionNum = serverNum - nowNum;

    //获取本机的ip地址
    NSString *macIp = [self getDeviceIPAddress];
    
    if([self.serverIp isEqualToString:macIp]){
        
        NSString *ipaddress = [NSString stringWithFormat:@"\n设备IP地址正常,服务器设备IP为:%@",self.serverIp];
        
        [self.contentStr appendFormat:@"%@", ipaddress];
        
        self.isRight = YES;

    }else{
        
        NSString *ipaddress = [NSString stringWithFormat:@"\n设备IP地址异常,服务器设备IP为:%@",self.serverIp];
        
        [self.contentStr appendFormat:@"%@", ipaddress];
        
        self.isRight = NO;

    }
    
    if(reductionNum > 1000){
        
        NSString *time = [NSString stringWithFormat:@"\n设备时间检查异常,服务器时间为:%@",self.serverTime];
        
        [self.contentStr appendFormat:@"%@", time];
            
        self.isTrue = NO;
        
    }else{
        
        NSString *time = [NSString stringWithFormat:@"\n设备时间检查正常,服务器时间为:%@",self.serverTime];

        [self.contentStr appendFormat:@"%@", time];

        self.isTrue = YES;
    }
}



/** 保留数据到本地 */
-(void)saveData:(NSString *)isNormal{
    
    //获取系统当前时间
    NSDate *currentDate = [NSDate date];
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    //NSDate转NSString
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    
    NSString *status = @"正常";
    
    if([isNormal isEqualToString:@"1"]){
        
        status = @"正常";
        
    }else{
        
        status = @"异常";
    }
    
    NSDictionary *dict = @{@"time":currentDateString,@"status":status,@"desc":self.contentStr};
    
//    如果本地化的数组有值，那么先加进去
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"status"];

    self.sumArray = [NSMutableArray array];

    if(array.count > 0){
    
        [self.sumArray addObjectsFromArray:array];
    }
    
    [self.sumArray addObject:dict];

    //存入数组并同步
    [[NSUserDefaults standardUserDefaults] setObject:self.sumArray forKey:@"status"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [KNotification postNotificationName:@"HistoryRecordViewController" object:nil userInfo:nil];
    
}

#pragma mark --- 获取设备ip地址

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

@end
