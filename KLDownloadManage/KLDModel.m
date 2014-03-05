//
//  KLDModel.m
//  KLDownloadManage
//
//  Created by Glen on 14-2-18.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import "KLDModel.h"
#import <objc/objc-runtime.h>

@implementation KLDModel
- (id)initWithTaskWithURL:(NSString *)furl filename:(NSString *)filename type:(TaskType)type
{
    if((self = [super init]))
    {
        self.dm_isFirstReceive = YES;
        self.dm_name = filename;
        self.dm_url = furl;
        self.taskType = type;
    }
    return self;
}
@end
