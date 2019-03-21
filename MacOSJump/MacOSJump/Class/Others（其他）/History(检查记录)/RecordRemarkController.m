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

    self.content.stringValue = self.alertStr;
}



@end
