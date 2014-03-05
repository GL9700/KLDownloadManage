//
//  KLFileManage.m
//  KLDownloadManage
//
//  Created by Glen on 14-2-21.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import "KLFileManage.h"

@implementation KLFileManage
+ (BOOL)createDirectory:(NSString *)path
{
    BOOL success = YES;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    success = [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if(success==NO)
    {
        NSLog(@"%@" , error);
    }
    return success;
}
+ (BOOL)saveFileWithPath:(NSString *)path content:(id)content
{
    if(![content isKindOfClass:[NSArray class]] && ![content isKindOfClass:[NSDictionary class]])
        return NO;
    if([content writeToFile:path atomically:YES])
        return YES;
    return NO;
}
+ (BOOL)removeFileWithPath:(NSString *)path
{
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm removeItemAtPath:path error:&error])
        return YES;
    else
    {
        return NO;
        assert(0);
    }
}
+ (NSArray *)getFilesPathWithFolder:(NSString *)path withSuffix:(NSString *)suffix
{
    NSFileManager *filemanage = [NSFileManager defaultManager];
    NSArray *t = [filemanage contentsOfDirectoryAtPath:path error:nil];
    NSMutableArray *result = [NSMutableArray array];
    for(int i = 0 ; i<[t count]; i++)
    {
        NSString *str = [t[i] pathExtension];
        if(str.length>0 && [[t[i] pathExtension] isEqualToString:suffix])
        {
            [result addObject:[path stringByAppendingPathComponent:t[i]]];
        }
    }
    return result;
}
+ (NSDictionary *)getFileAttributes:(NSString *)path
{
    NSError *error = nil;
    NSFileManager *filemanage = [NSFileManager defaultManager];
    return [filemanage attributesOfItemAtPath:path error:&error];
}

+ (NSDictionary *)getDiskSpaceInfo
{
    uint64_t totalSpace = 0.0f;
    uint64_t freeSpace = 0.0f;
    NSError *error = nil;
    NSString *paths = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:paths error: &error];
    if (dictionary)
    {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes floatValue];
        freeSpace = [freeFileSystemSizeInBytes floatValue];
    }
    else
        return nil;
    double totalSpaceFloat = totalSpace/1024.f;
    double freeSpaceFloat = freeSpace/1024.f;
    double usedSpaceFloat = (totalSpaceFloat - freeSpaceFloat);
    NSString *totalSpaceStr = [NSString stringWithFormat:@"%.1f" , totalSpaceFloat];
    NSString *freeSpaceStr  = [NSString stringWithFormat:@"%.1f" , freeSpaceFloat];
    NSString *usedSpaceStr = [NSString stringWithFormat:@"%.1f" , usedSpaceFloat];
    return @{@"total" : totalSpaceStr , @"used" : usedSpaceStr ,@"free" : freeSpaceStr};
}
@end