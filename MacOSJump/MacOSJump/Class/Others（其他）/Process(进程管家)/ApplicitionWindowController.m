//
//  ApplicitionWindowController.m
//  MacOSJump
//
//  Created by jumpapp1 on 2019/3/15.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "ApplicitionWindowController.h"
#import "ApplicitionModel.h"

@interface ApplicitionWindowController ()<NSTableViewDelegate,NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *tableView;
//获取进程列表
@property (strong,nonatomic) NSMutableArray<ApplicitionModel *> *dataArray;

@end

@implementation ApplicitionWindowController


-(NSMutableArray<ApplicitionModel *> *)dataArray{
    
    if(!_dataArray){
        
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (void)windowDidLoad {
    [super windowDidLoad];

    self.tableView.delegate = self;
    
    self.tableView.dataSource = self;
    
    [self.tableView setDoubleAction:@selector(doubleAction:)];
    
    
    [self getAppName];
    
    //监听当有程序启动时，重新获取进程
    [[[NSWorkspace sharedWorkspace]notificationCenter] addObserver:self selector:@selector(getAppName) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
}



#pragma mark --- 获取进程名称

-(void)getAppName{
    
    //获取正在运行的app名称
    NSArray<NSRunningApplication *> *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    
    for (NSRunningApplication *app in apps) {
        
        ApplicitionModel *model = [[ApplicitionModel alloc]initApplationModelName:app.localizedName bundleURL:app.bundleURL processIdentifier:app.processIdentifier launchDate:app.launchDate icon:app.icon];
        
        [self.dataArray addObject:model];
    }
    
    [self.tableView reloadData];
}


#pragma mark --- NSTableViewDelegate,NSTableViewDataSource


-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    
    return self.dataArray.count;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    ApplicitionModel *model = self.dataArray[row];
    
    if([tableColumn.identifier isEqualToString:@"oneColumn"]){
        
        NSTableCellView *oneCell = [tableView makeViewWithIdentifier:@"oneCell" owner:self];
        
        oneCell.imageView.image = model.icon;
        
        oneCell.textField.stringValue = model.localizedName;
        
        oneCell.toolTip = model.bundleURL.path;
        
        return oneCell;
        
    }else if ([tableColumn.identifier isEqualToString:@"twoColumn"]){
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        
        NSString *dataString = [dateFormatter stringFromDate:model.launchDate]?:@"";
        
        NSTableCellView *twoCell = [tableView makeViewWithIdentifier:@"twoCell" owner:self];
        
        //        twoCell.textField.stringValue = [NSString stringWithFormat:@"%@",model.launchDate];
        
        twoCell.textField.stringValue = dataString;
        
        return twoCell;
    }
    
    NSTableCellView *threeCell = [tableView makeViewWithIdentifier:@"threeCell" owner:self];
    
    threeCell.textField.stringValue = [NSString stringWithFormat:@"%d",model.processIdentifier];
    
    return threeCell;
}


//双击方法(点击关闭，需要关闭沙盒机制)

-(void)doubleAction:(NSTableView *)tableView{
    
    NSInteger selectRow = tableView.selectedRow;
    
    ApplicitionModel *model = self.dataArray[selectRow];
    
    NSAlert *alert = [[NSAlert alloc]init];
    
    alert.informativeText = @"是否结束该进程";
    alert.messageText = @"温馨提示";
    alert.alertStyle = NSAlertStyleWarning;
    
    [alert addButtonWithTitle:@"确定"];
    [alert addButtonWithTitle:@"取消"];
    
    __weak typeof (self) weakself = self;
    
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        
        if(returnCode == 1000){
            //确定
            
            kill(model.processIdentifier, SIGKILL);
            
            [weakself.dataArray removeObject:model];
            
            [weakself.tableView reloadData];
        }
    }];
    
}

@end
