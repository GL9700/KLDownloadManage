//
//  KLDownloadViewController.m
//  KLDownloadManage
//
//  Created by Glen on 14-2-19.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import "KLDownloadViewController.h"
#import "IKULoadCell.h"
#import "KLDModel.h"
@implementation KLDownloadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        downloadManage = [KLDownloadManage sharedDownloadManageWithModelClass:[KLDModel class]];
        [downloadManage setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *barbuttonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSelf:)];
    [self.navigationItem setLeftBarButtonItem:barbuttonItem];
    UIBarButtonItem *bbL3 = [[UIBarButtonItem alloc]initWithTitle:@"全部开始"
                                                            style:UIBarButtonItemStyleBordered
                                                           target:self
                                                           action:@selector(startTasks:)];
    UIBarButtonItem *bbL4 = [[UIBarButtonItem alloc]initWithTitle:@"全部停止"
                                                            style:UIBarButtonItemStyleBordered
                                                           target:self
                                                           action:@selector(stopTasks:)];
    [self.navigationItem setRightBarButtonItems:@[bbL3 , bbL4]];
}
- (void)startSingleTask:(id)sender
{
    
}
- (void)stopSingleTask:(id)sender
{
    
}
- (void)startTasks:(id)sender
{
    [downloadManage startList];
}
- (void)stopTasks:(id)sender
{
    [downloadManage pauseList];
}
- (void)cancelSelf:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)taskUpdateProgressWithModel:(KLModelBase *)model
{
    NSArray *array = tableview.visibleCells;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for(IKULoadCell *cell in array)
        {
            if([cell.titleLabel.text isEqualToString:[(KLDModel *)model titleName]])
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    long long load , total;
                    load = atoll([model.dm_loadedByte UTF8String]);
                    total = atoll([model.dm_totalByte UTF8String]);
                    float pro = ((float)load/total);
                    [cell.progressView setProgress:pro];
                });
            }
        }
    });
}
- (void)taskError:(KLModelBase *)model
{
    NSLog(@"%@ 下载失败" , model.dm_name);
    assert(0);
}
- (void)taskFinish:(KLModelBase *)model
{
    NSLog(@"%@ 下载完成" , model.dm_name);
    assert(0);
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int num = [[downloadManage getDownloadingList] count];
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IKULoadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"d"];
    if(!cell)
        cell = [[IKULoadCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"d"];
    KLDModel *mb = [[downloadManage getDownloadingList] objectAtIndex:indexPath.row];
    if([mb isKindOfClass:[KLDModel class]])
        cell.titleLabel.text = mb.titleName;
    return cell;
}


@end
