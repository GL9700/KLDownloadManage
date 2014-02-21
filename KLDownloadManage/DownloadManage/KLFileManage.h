//
//  KLFileManage.h
//  KLDownloadManage
//
//  Created by Glen on 14-2-21.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KLFileManage : NSObject
+ (BOOL)removeFileWithPath:(NSString *)path;
+ (NSArray *)getFilesPathWithFolder:(NSString *)path;
@end
