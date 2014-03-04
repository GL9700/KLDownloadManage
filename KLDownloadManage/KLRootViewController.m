//
//  KLRootViewController.m
//  KLDownloadManage
//
//  Created by Glen on 14-2-14.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import "KLRootViewController.h"
#import "KLDownloadViewController.h"

@implementation KLRootViewController

- (id)init
{
    if((self = [super init])){
        dataSource = @[
                       @{@"name" : @"QQ 5.0" , @"URL" : @"http://dldir1.qq.com/qqfile/qq/QQ5.0/9857/QQ5.0.exe"},
                       @{@"name" : @"电脑管家" , @"URL" : @"http://dlied6.qq.com/invc/xfspeed/qqpcmgr/download/QQPCDownload140063.exe"},
                       @{@"name" : @"软件管理" , @"URL" : @"http://dldir2.qq.com/invc/xfspeed/softmgr/SoftMgr_Setup_S40001.exe"},
                       @{@"name" : @"QQ音乐" , @"URL" : @"http://dldir1.qq.com/music/clntupate/QQMusic_Setup_2014.exe"},
                       @{@"name" : @"QQ浏览器" , @"URL" : @"http://dldir1.qq.com/invc/tt/QQBrowserSetup.exe"},
                       @{@"name" : @"QQ影像" , @"URL" : @"http://dldir1.qq.com/invc/qqimage/QQImage_Setup_30_890.exe"},
                       @{@"name" : @"QQ输入法" , @"URL" : @"http://dl_dir.qq.com/invc/qqpinyin/QQPinyin_Setup_4.6.2028.400.exe"},
                       @{@"name" : @"TM2013" , @"URL" : @"http://dldir1.qq.com/qqfile/tm/TM2013Preview1.exe"},
                       @{@"name" : @"M3U8" , @"URL" : @"http://192.168.100.83:8111/product/play_video?im=bcd2faa17470722b50bf6b03fdb02662005613b286263614ce9d8585ca082ccb&vendor=koolearn&protocol_version=1.0&app_id=126&os_type=iphone&record_id=0&platform=ios_iphone_7.0.3&version=1&app_name=%E6%96%B0%E4%B8%9C%E6%96%B9%E5%9C%A8%E7%BA%BF&sid=89a9d4de6a116eefac3816a0d85f25d6bd28c4c58e5db452&unit_id=608601&model=apple&account_id=0&sign=bcc233ad90a88dd9c02ba4361baf5d61&network=wifi&screensize=640*960"}
                       ];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *barbuttonItem = [[UIBarButtonItem alloc]initWithTitle:@"进入下载列表"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(enterDownloadPage:)];
    [self.navigationItem setRightBarButtonItem:barbuttonItem];
    
    manage = [KLDownloadManage sharedDownloadManageWithModelClass:[KLDModel class]];
    NSArray *array =[manage getDownloadingList];
    downloadingName = [NSMutableArray array];
    for(KLDModel *dm in array)
    {
        [downloadingName addObject:dm.name];
    }
}

- (void)enterDownloadPage:(UIBarButtonItem *)sender
{
    KLDownloadViewController *dvc = [[KLDownloadViewController alloc]init];
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:dvc];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"c"];
    if(!cell)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"c"];
    [cell.textLabel setText:[[dataSource objectAtIndex:indexPath.row] objectForKey:@"name"]];
    [cell.detailTextLabel setText:dataSource[indexPath.row][@"URL"]];
    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSError *error = nil;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    TaskType type = TaskType_SingleFile;
    if([cell.textLabel.text isEqualToString:@"M3U8"])
    {
        type = TaskType_M3U8;
    }
    dmodel = [[KLDModel alloc]initWithTaskWithURL:cell.detailTextLabel.text filename:cell.textLabel.text  type:type];
    [dmodel setTitleName:cell.textLabel.text];
    [dmodel setDirectory:@"abc"];
    if([manage addTask:dmodel autoStart:YES error:&error])
    {
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }else{
        NSLog(@"%@" , error);
    }
    [self enterDownloadPage:nil];
}

@end

