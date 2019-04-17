//
//  FirstPageViewController.h
//  MacOSJump
//
//  Created by jumpapp1 on 2019/3/19.
//  Copyright © 2019年 zb. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface FirstPageViewController : NSViewController

//保存的数据
@property (strong,nonatomic) NSDictionary *dataDict;
//设备id
@property (copy,nonatomic) NSString *devnewId;
//需要关闭的窗口
@property (strong,nonatomic) NSWindow *rewindow;

@end

NS_ASSUME_NONNULL_END
