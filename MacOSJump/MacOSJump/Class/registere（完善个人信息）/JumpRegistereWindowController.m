//
//  JumpRegistereWindowController.m
//  MacOSJump
//
//  Created by jumpapp1 on 2019/4/3.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "JumpRegistereWindowController.h"
#import "JumploginRegistereViewController.h"


@interface JumpRegistereWindowController ()

@property (strong,nonatomic) JumploginRegistereViewController *rgistereVC;


@end

@implementation JumpRegistereWindowController


- (void)windowDidLoad {
    [super windowDidLoad];
    
    AppDelegate *appdelegate = [NSApp delegate];
    
    appdelegate.windowVc = self;

    
    self.window.restorable = NO;
    
    [self.window setContentSize:NSMakeSize(800, 600)];
    
    self.window.restorable = NO;
    
    self.rgistereVC = [[JumploginRegistereViewController alloc]initWithNibName:@"JumploginRegistereViewController" bundle:nil];
    
    self.rgistereVC.redataDict = self.redataDict;
    
    self.rgistereVC.deviceCode = self.deviceCode;
    
    self.rgistereVC.isCheck = self.isCheck;
    
    self.rgistereVC.rewindow = self.window;
    
    [self.window setContentView:self.rgistereVC.view];
    
}

@end
