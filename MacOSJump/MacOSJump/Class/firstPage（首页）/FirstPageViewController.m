//
//  FirstPageViewController.m
//  MacOSJump
//
//  Created by jumpapp1 on 2019/3/19.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "FirstPageViewController.h"

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

@end

@implementation FirstPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self progressStatus];

}


-(void)progressStatus{
    
    L2CWeakSelf(self);
    
    self.progress.doubleValue = 0;
    
    self.itemContent.stringValue = @"";
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5f repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        NSInteger progressV = weakself.progress.doubleValue;
        
        if(progressV >= 100){
            
            weakself.progress.doubleValue = 100;
            
            [weakself.timer invalidate];
            
            weakself.timer = nil;
            
            self.againBtn.enabled = YES;
            
        }else{
            
            [weakself.progress incrementBy:1];
            
            self.againBtn.enabled = NO;
            
        }
        weakself.itemContent.stringValue = [self isgo:progressV];
        
        
    }];
}

#pragma mark --- 进度判断

-(NSString *)isgo:(NSInteger)progressV{
    
    NSMutableString *contentStr = [NSMutableString string];
    
    if(progressV > 0){
        
        [contentStr appendFormat:@"正在检测..."];
    }
    
    if(progressV >= 20){
        
        [contentStr appendFormat:@"\n检查项1正常..."];
    }
    
    if(progressV >= 45){
        
        [contentStr appendFormat:@"\n检查项2正常..."];
    }
    
    if(progressV >= 60){
        
        [contentStr appendFormat:@"\n检查项3正常..."];
    }
    
    if(progressV > 99){
        
        [contentStr appendFormat:@"\n检查项4正常..."];
    }
    
    return contentStr;
}


- (IBAction)backAction:(NSButton *)sender {
    
    
    [self progressStatus];
}


@end
