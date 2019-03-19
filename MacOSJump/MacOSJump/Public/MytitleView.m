//
//  MytitleView.m
//  MacOSJump
//
//  Created by jumpapp1 on 2019/3/18.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "MytitleView.h"

@implementation MytitleView

- (void)drawString:(NSString *)string inRect:(NSRect)rect {
    static NSDictionary *att = nil;
    if (!att) {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];
        [style setAlignment:NSTextAlignmentCenter];
        att = [[NSDictionary alloc] initWithObjectsAndKeys: style, NSParagraphStyleAttributeName,[NSColor whiteColor], NSForegroundColorAttributeName,[NSFont fontWithName:@"Helvetica" size:12], NSFontAttributeName, nil];
    }
    
    NSRect titlebarRect = NSMakeRect(rect.origin.x+20, rect.origin.y-4, rect.size.width, rect.size.height);
    
    
    [string drawInRect:titlebarRect withAttributes:att];
}


-(void)drawRect:(NSRect)dirtyRect
{
     [super drawRect:dirtyRect];
    NSRect windowFrame = [NSWindow  frameRectForContentRect:[[[self window] contentView] bounds] styleMask:[[self window] styleMask]];
    NSRect contentBounds = [[[self window] contentView] bounds];
    
    NSRect titlebarRect = NSMakeRect(0, 0, self.bounds.size.width, windowFrame.size.height - contentBounds.size.height);
    titlebarRect.origin.y = self.bounds.size.height - titlebarRect.size.height;
    
    NSRect topHalf, bottomHalf;
    NSDivideRect(titlebarRect, &topHalf, &bottomHalf, floor(titlebarRect.size.height / 2.0), NSMaxYEdge);
    
    NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:4.0 yRadius:4.0];
    [[NSBezierPath bezierPathWithRect:titlebarRect] addClip];
    
    
    
    NSGradient * gradient1 = [[NSGradient alloc] initWithStartingColor:RGB(0, 122, 255) endingColor:RGB(0, 122, 255)];
    
    NSGradient * gradient2 = [[NSGradient alloc] initWithStartingColor:RGB(0, 122, 255) endingColor:RGB(0, 122, 255)];
    
    [path addClip];
    
    [gradient1 drawInRect:topHalf angle:270.0];
    [gradient2 drawInRect:bottomHalf angle:270.0];
    
    [[NSColor blueColor] set];
    NSRectFill(NSMakeRect(0, -4, self.bounds.size.width, 1.0));
    
    
    [self drawString:@"捷普准入控制系统" inRect:titlebarRect];
    
    
}

@end
