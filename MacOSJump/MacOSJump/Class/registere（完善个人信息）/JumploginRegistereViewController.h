//
//  JumploginRegistereViewController.h
//  MacOSJump
//
//  Created by jumpapp1 on 2019/4/17.
//  Copyright © 2019年 zb. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface JumploginRegistereViewController : NSViewController

//设备唯一识别码
@property (copy,nonatomic) NSString *deviceCode;

//注册成功后本地保存数据
@property (copy,nonatomic) NSDictionary *redataDict;

@property (strong,nonatomic) NSWindow *rewindow;

@end

NS_ASSUME_NONNULL_END
