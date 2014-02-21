//
//  KLFileManage.m
//  KLDownloadManage
//
//  Created by Glen on 14-2-21.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import "KLFileManage.h"

@implementation KLFileManage
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
+ (NSArray *)getFilesPathWithFolder:(NSString *)path
{
    BOOL recursive = NO;
    NSMutableArray *fileDirectory =[NSMutableArray array];
    NSFileManager *filemanage = [NSFileManager defaultManager];
    NSArray *t = [filemanage contentsOfDirectoryAtPath:path error:nil];
    [fileDirectory addObject:[path lastPathComponent]];
    
    [filemanage fileExistsAtPath:NO isDirectory:NO];
    
    if(recursive)
        for(int i =0;i<[t count];i++)
        {
            NSString *str =[t objectAtIndex:i];
//            [fileDirectory addObject: [self contentsFileForPath:[path stringByAppendingPathComponent:str] recursive:recursive]];
            [fileDirectory addObject:[KLFileManage getFilesPathWithFolder:[path stringByAppendingPathComponent:str]]];
        }
    else
        [fileDirectory addObjectsFromArray:t];
    return fileDirectory;
}
@end
