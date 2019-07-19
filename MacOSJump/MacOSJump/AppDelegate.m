//
//  AppDelegate.m
//  MacOSJump
//
//  Created by jumpapp1 on 2019/1/14.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "AppDelegate.h"
#import "MytitleView.h"

@interface AppDelegate ()

@property (strong,nonatomic) NSStatusItem *statusItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [self addSmallicon];

    self.mainWindowC = [[MainWindowController alloc]initWithWindowNibName:@"MainWindowController"];
    
    [[self.mainWindowC window] center];
    
    [self.mainWindowC.window setBackgroundColor:BackGroundColor];
    
//    NSRect boundsRect = [[[self.mainWindowC.window contentView] superview] bounds];
//    
//    MytitleView * titleview = [[MytitleView alloc] initWithFrame:boundsRect];
//
//    [titleview setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
//
//    [[[self.mainWindowC.window contentView] superview] addSubview:titleview positioned:NSWindowBelow relativeTo:[[[[self.mainWindowC.window contentView] superview] subviews] objectAtIndex:0]];
    
    [self.mainWindowC.window orderFront:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"MacOSJump"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving and Undo support

- (IBAction)saveAction:(id)sender {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    NSManagedObjectContext *context = self.persistentContainer.viewContext;

    if (![context commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if (context.hasChanges && ![context save:&error]) {
        // Customize this code block to include application-specific recovery steps.              
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    return self.persistentContainer.viewContext.undoManager;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    NSManagedObjectContext *context = self.persistentContainer.viewContext;

    if (![context commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (!context.hasChanges) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![context save:&error]) {

        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertSecondButtonReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

//-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
//
//    return YES;
//}


//添加小图标
-(void)addSmallicon{
    
    NSStatusBar *itemBar = [NSStatusBar systemStatusBar];
    
    self.statusItem = [itemBar statusItemWithLength:NSSquareStatusItemLength];
    
    self.statusItem.target = self;
    
    self.statusItem.image = [NSImage imageNamed:@"logo_2"];
    
    NSMenu *menu = [[NSMenu alloc]initWithTitle:@"StatusMenu"];
    
    [menu addItemWithTitle:@"打开应用" action:@selector(openAction) keyEquivalent:@""];
    [menu addItemWithTitle:@"退出应用" action:@selector(outAction) keyEquivalent:@""];
    
    self.statusItem.menu = menu;
    
}


//打开应用
-(void)openAction{
    
    [self.windowVc.window makeKeyAndOrderFront:self];
}

//退出应用
-(void)outAction{
    
    [[NSApplication sharedApplication] terminate:self];
}



-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{
    
    [self.windowVc.window makeKeyAndOrderFront:self];
    
    return YES;
}



@end
