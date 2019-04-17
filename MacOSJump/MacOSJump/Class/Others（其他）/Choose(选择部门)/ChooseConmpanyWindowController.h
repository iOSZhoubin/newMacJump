//
//  ChooseConmpanyWindowController.h
//  MacOSJump
//
//  Created by jumpapp1 on 2019/3/5.
//  Copyright © 2019年 zb. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ChooseCompanyDelegate<NSObject>

-(void)selectCompany:(NSMutableDictionary *)selectDict;

@end

@interface ChooseConmpanyWindowController : NSWindowController

@property (weak,nonatomic) id<ChooseCompanyDelegate> delegate;

//准备保存在钥匙串中的字典
@property (strong,nonatomic) NSDictionary *dict;

@end
