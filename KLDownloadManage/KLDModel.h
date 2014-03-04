//
//  KLDModel.h
//  KLDownloadManage
//
//  Created by Glen on 14-2-18.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLModelBase.h"

@interface KLDModel : KLModelBase
@property (nonatomic , strong) NSString *titleName;
- (id)initWithTaskWithURL:(NSString *)furl filename:(NSString *)filename type:(TaskType)type;
@end
