//
//  MainWindowController.m
//  MacOSJump
//
//  Created by jumpapp1 on 2019/1/14.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "MainWindowController.h"
#import "JumpLoginViewController.h"


@interface MainWindowController ()

@property (strong,nonatomic) JumpLoginViewController *loginVC;

@end

@implementation MainWindowController


- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setContentSize:NSMakeSize(800, 600)];

    self.window.restorable = NO;
    
    self.loginVC = [[JumpLoginViewController alloc]initWithNibName:@"JumpLoginViewController" bundle:nil];
    
    self.loginVC.mainWC = self.window;
    
   [self.window setContentView:self.loginVC.view];
        
}

@end
