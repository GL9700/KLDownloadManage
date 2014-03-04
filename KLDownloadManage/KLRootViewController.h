//
//  KLRootViewController.h
//  KLDownloadManage
//
//  Created by Glen on 14-2-14.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLDownloadManage.h"
#import "KLDModel.h"

@interface KLRootViewController : UIViewController <UITableViewDataSource , UITableViewDelegate>
{
    NSArray *dataSource;
    KLDownloadManage *manage;
    KLDModel *dmodel;
    NSMutableArray *downloadingName;
}
@end
