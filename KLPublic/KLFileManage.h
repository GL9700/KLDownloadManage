//
//  KLFileManage.h
//  KLDownloadManage
//
//  Created by Glen on 14-2-21.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KLFileManage : NSObject
//+ (BOOL)fileIsExist:(NSString *)path isDirectory:(BOOL)directory;
+ (BOOL)createDirectory:(NSString *)path;
+ (BOOL)saveFileWithPath:(NSString *)path content:(id)content;
+ (BOOL)removeFileWithPath:(NSString *)path;
+ (NSArray *)getFilesPathWithFolder:(NSString *)path withSuffix:(NSString *)suffix;
+ (NSDictionary *)getFileAttributes:(NSString *)path;
+ (NSDictionary *)getDiskSpaceInfo;

@end