//
//  KLDownloadViewController.h
//  KLDownloadManage
//
//  Created by Glen on 14-2-19.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLDownloadManage.h"
@class KLDownloadViewController;
@interface KLDownloadViewController : UIViewController <UITableViewDataSource , UITableViewDelegate , KLDownloadManageDelegate>
{
    KLDownloadManage *downloadManage;
}
@end
