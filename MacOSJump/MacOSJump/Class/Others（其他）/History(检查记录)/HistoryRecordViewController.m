//
//  HistoryRecordViewController.m
//  MacOSJump
//
//  Created by jumpapp1 on 2019/3/19.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "HistoryRecordViewController.h"
#import "RecordRemarkController.h"

@interface HistoryRecordViewController ()<NSTableViewDelegate,NSTableViewDataSource>

//tableview
@property (weak) IBOutlet NSTableView *tableView;
//数据源
@property (strong,nonatomic) NSMutableArray *dataArray;
//提示框
@property(nonatomic,strong) NSPopover *firstPopover;
//提示框
@property(nonatomic,strong) RecordRemarkController *recordVC;


@end

@implementation HistoryRecordViewController



- (NSPopover *)firstPopover
{
    if(!_firstPopover)
    {
        _firstPopover=[[NSPopover alloc]init];
        
        _firstPopover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
        
        _firstPopover.contentViewController = self.recordVC;
        
        _firstPopover.behavior = NSPopoverBehaviorTransient;
        
        _firstPopover.contentSize = NSMakeSize(400, 100);
        
    }
    return _firstPopover;
}

- (RecordRemarkController *)recordVC
{
    if(!_recordVC)
    {
        _recordVC = [[RecordRemarkController alloc]init];
    }
    return _recordVC;
}


-(NSMutableArray *)dataArray{
    
    if(!_dataArray){
        
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    
    self.tableView.dataSource = self;
    
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"status"];

    self.dataArray = array.mutableCopy;

    [self.tableView reloadData];
    
    [KNotification addObserver:self selector:@selector(notifi:) name:@"HistoryRecordViewController" object:nil];

}



- (void)notifi:(NSNotification *)note{
    
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"status"];
    
    self.dataArray = array.mutableCopy;
    
    [self.tableView reloadData];
}



#pragma mark --- NSTableViewDelegate,NSTableViewDataSource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    
    return self.dataArray.count;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    
    if([tableColumn.identifier isEqualToString:@"oneColumn"]){
        
        NSTableCellView *oneCell = [tableView makeViewWithIdentifier:@"oneCell" owner:self];
        
        oneCell.textField.stringValue = self.dataArray[row][@"time"];
        
        return oneCell;
        
    }else{
        
        NSTableCellView *twoCell = [tableView makeViewWithIdentifier:@"twoCell" owner:self];
        
        twoCell.textField.stringValue = self.dataArray[row][@"status"];
        
        return twoCell;
    }
}


#pragma mark --- NSOutlineViewDelegate

//单击某一行
- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    
    NSTableView *tableView = notification.object;
    
    NSInteger selectRow = tableView.selectedRow;
    
    if(self.dataArray.count > 0 && selectRow >= 0){
        
        self.recordVC.alertStr = self.dataArray[selectRow][@"desc"];
    }
    
    NSLog(@"1:点击了第%ld行",selectRow);
    
    if(selectRow >= 0 ){
        
        [self.firstPopover showRelativeToRect:CGRectMake(260, 25 * self.dataArray.count, 200, 200) ofView:self.view preferredEdge:NSRectEdgeMaxX];
    }
}


#pragma mark --- 清空记录

- (IBAction)deleteRecords:(NSButton *)sender {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"status"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    self.dataArray = nil;
    
    [self.tableView reloadData];
}

-(void)dealloc{
    
    [KNotification removeObserver:self];
}

@end
