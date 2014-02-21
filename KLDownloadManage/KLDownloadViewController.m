//
//  KLDownloadViewController.m
//  KLDownloadManage
//
//  Created by Glen on 14-2-19.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import "KLDownloadViewController.h"
#import "IKULoadCell.h"
@implementation KLDownloadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        downloadManage = [KLDownloadManage sharedDownloadManage];
        [downloadManage setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *barbuttonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSelf:)];
    [self.navigationItem setLeftBarButtonItem:barbuttonItem];

}
- (void)cancelSelf:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateProgress:(id<KLModelProtocal>)model progress:(float)progressFloat
{
    NSLog(@"%f" , progressFloat);
}



- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[downloadManage getDownloadingList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IKULoadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"d"];
    if(!cell)
        cell = [[IKULoadCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"d"];
    NSOperationQueue *q = [[downloadManage getDownloadingList] objectAtIndex:indexPath.row];
    cell.titleLabel.text = q.name;
    return cell;
}


@end
