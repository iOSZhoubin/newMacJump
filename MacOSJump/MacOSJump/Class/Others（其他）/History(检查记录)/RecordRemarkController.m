//
//  RecordRemarkController.m
//  MacOSJump
//
//  Created by jumpapp1 on 2019/3/19.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "RecordRemarkController.h"

@interface RecordRemarkController ()

@property (weak) IBOutlet NSTextField *content;


@end

@implementation RecordRemarkController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.content.stringValue = @"检查项1正常.\n检查项2正常.\n检查项3正常.\n检查项4正常.";
}



@end
