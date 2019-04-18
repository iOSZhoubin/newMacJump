//
//  FirstPageTabController.m
//  MacOSJump
//
//  Created by jumpapp1 on 2019/3/19.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "FirstPageTabController.h"
#import "FirstPageViewController.h"
#import "JumpRegistereViewController.h"
#import "HistoryRecordViewController.h"
#import "JumpStatusViewController.h"
//进程管家
#import "ApplicitionViewController.h"

@interface FirstPageTabController ()

//检测
@property (weak) IBOutlet NSTabViewItem *firstItem;
//状态
@property (weak) IBOutlet NSTabViewItem *secondItem;
//完善信息
@property (weak) IBOutlet NSTabViewItem *thirdItem;
//检测记录
@property (weak) IBOutlet NSTabViewItem *fourthItem;
//进程管家
@property (weak) IBOutlet NSTabViewItem *fifthItem;

@property (strong,nonatomic) FirstPageViewController *firstVc;

@property (strong,nonatomic) JumpRegistereViewController *registereVC;

@property (strong,nonatomic) HistoryRecordViewController *historyVC;

@property (strong,nonatomic) JumpStatusViewController *jumpStatusVC;

@property (strong,nonatomic) ApplicitionViewController *applicitionVC;



@end

@implementation FirstPageTabController

- (void)windowDidLoad {
    [super windowDidLoad];
  
//    self.firstVc = [[FirstPageViewController alloc]initWithNibName:@"FirstPageViewController" bundle:nil];
//
//    self.firstItem.view = self.firstVc.view;
   
    
    self.jumpStatusVC = [[JumpStatusViewController alloc]initWithNibName:@"JumpStatusViewController" bundle:nil];
    
    self.secondItem.view = self.jumpStatusVC.view;
    
    
    self.registereVC = [[JumpRegistereViewController alloc]initWithNibName:@"JumpRegistereViewController" bundle:nil];
    
    self.fourthItem.view = self.registereVC.view;
    
    
    self.historyVC = [[HistoryRecordViewController alloc]initWithNibName:@"HistoryRecordViewController" bundle:nil];

    self.thirdItem.view = self.historyVC.view;
    
//    self.applicitionVC = [[ApplicitionViewController alloc]initWithNibName:@"ApplicitionViewController" bundle:nil];
//
//    self.fifthItem.view = self.applicitionVC.view;

    [self.window setContentSize:NSMakeSize(800, 600)];
    
    self.window.restorable = NO;
}

@end
