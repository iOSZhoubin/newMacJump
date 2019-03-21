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
//允许应用安装检查Array
@property (strong,nonatomic) NSMutableArray *installY;
//禁止应用安装检查Array
@property (strong,nonatomic) NSMutableArray *installN;
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
    
    self.installY = [NSMutableArray array];
    self.installN = [NSMutableArray array];
    self.processY = [NSMutableArray array];
    self.processN = [NSMutableArray array];
    self.sumArray = [NSMutableArray array];
    
    [self getAllCheck];

    [self progressStatus];
}


-(void)progressStatus{
    
    L2CWeakSelf(self);
    
    self.progress.doubleValue = 0;
    
    self.itemContent.stringValue = @"";
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5f repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        weakself.progressV = weakself.progress.doubleValue;
        
        if(weakself.progressV >= 100){
            
            weakself.progress.doubleValue = 100;
            
            [weakself.timer invalidate];
            
            weakself.timer = nil;
            
            self.againBtn.enabled = YES;
            
            self.itemContent.stringValue = self.contentStr;
            
        }else{
            
            [weakself.progress incrementBy:1];
            
            self.itemContent.stringValue = @"正在检测...\n";
            
            self.againBtn.enabled = NO;
            
        }
        
    }];
}

#pragma mark --- 进度判断
//
//-(NSString *)isgo:(NSInteger)progressV{
//
//    NSMutableString *contentStr = [NSMutableString string];
//
//    if(progressV > 0){
//
//        [contentStr appendFormat:@"正在检测..."];
//    }
//
//    if(progressV >= 20){
//
//        [contentStr appendFormat:@"\n允许或禁止应用检查正常..."];
//    }
//
//    if(progressV >= 45){
//
//        [contentStr appendFormat:@"\n允许或禁止进程检查正常..."];
//    }
//
//    if(progressV >= 60){
//
//        [contentStr appendFormat:@"\n服务器IP地址检查正常..."];
//    }
//
//    if(progressV > 99){
//
//        [contentStr appendFormat:@"\n服务器时间检查正常..."];
//    }
//
//    return contentStr;
//}

#pragma mark --- 开始检测

- (IBAction)backAction:(NSButton *)sender {
    
    [self getAllCheck];
    
    [self progressStatus];
    
    [KNotification postNotificationName:@"HistoryRecordViewController" object:nil userInfo:nil];
}




#pragma mark --- 获取检查项

-(void)getAllCheck{
    
    L2CWeakSelf(self);
    
    NSDictionary *defaultDict = [JumpKeyChain getKeychainDataForKey:@"userInfo"];
    
    NSString *port = SafeString(defaultDict[@"port"]);
    
    NSString *ipAddress = SafeString(defaultDict[@"ipAddress"]);
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",ipAddress,port,Mac_CheckEntry];
    
    [AFNHelper macPost:urlStr parameters:@{@"userId":@"2"} success:^(id responseObject) {
        
        NSDictionary *dict = responseObject[@"result"];
        
        weakself.installY = dict[@"installY"];
        weakself.installN = dict[@"installN"];
        weakself.processY = dict[@"processY"];
        weakself.processN = dict[@"processN"];
        
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
    
    NSMutableArray *muArray = [NSMutableArray array];
    
    [muArray addObjectsFromArray:self.processN];
    
    [muArray addObjectsFromArray:self.processY];

    for (ApplicitionModel *model in self.dataArray) {
        
        NSString *name = model.localizedName;
        
        for (NSInteger i=0; i<muArray.count; i++) {
            
            NSString *proName = muArray[i][@"name"];
            
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
    
    self.contentStr = [NSMutableString string];
    
    [self.contentStr appendFormat:@"允许或禁止应用检查正常...\n允许或禁止进程检查正常..."];
    
    [self getServerInfo];
    
}



#pragma mark --- 获取服务器时间和IP地址

-(void)getServerInfo{
    
    L2CWeakSelf(self);
    
    NSDictionary *defaultDict = [JumpKeyChain getKeychainDataForKey:@"userInfo"];
    
    NSString *port = SafeString(defaultDict[@"port"]);
    
    NSString *ipAddress = SafeString(defaultDict[@"ipAddress"]);
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",ipAddress,port,Mac_ServerInfo];
    
    [AFNHelper macPost:urlStr parameters:@{@"userId":@"2"} success:^(id responseObject) {
        
        NSDictionary *dict = responseObject[@"result"];

        weakself.serverTime = dict[@"serverTime"];
        
        weakself.serverIp = dict[@"serverIp"];
        
        [weakself compareIpandTime];
        
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
    
    BOOL isRight = YES;
    BOOL isTrue = YES;

    if([self.serverIp isEqualToString:@""]){
        
        [self.contentStr appendFormat:@"\n服务器IP地址异常..."];

        isRight = NO;

    }else{
      
        [self.contentStr appendFormat:@"\n服务器IP地址检查正常..."];

        isRight = YES;

    }
    
    if(reductionNum > 1000){
        
        [self.contentStr appendFormat:@"\n服务器时间检查异常..."];
            
        isTrue = NO;
        
    }else{
        
        [self.contentStr appendFormat:@"\n服务器时间检查正常..."];
            
        isTrue = YES;
    }
    
    if(isRight==YES && isTrue==YES){
        
        [self saveData:@"1"];
        
    }else{
        
        [self saveData:@"0"];
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
    
    if(array.count > 0){
        
        [self.sumArray addObjectsFromArray:array];
    }
    
    [self.sumArray addObject:dict];

    //存入数组并同步
    [[NSUserDefaults standardUserDefaults] setObject:self.sumArray forKey:@"status"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [KNotification postNotificationName:@"HistoryRecordViewController" object:nil userInfo:nil];
}

@end
