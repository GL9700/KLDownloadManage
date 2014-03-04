//
//  KLModelProtocal.m
//  KLDownloadManage
//
//  Created by Glen on 14-2-25.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import <objc/objc-runtime.h>
#import "KLModelBase.h"
#import "KLFileManage.h"
#import "KLDMMacros.h"
@implementation KLModelBase

- (id)init
{
    if((self = [super init]))
    {
        _isFirstReceive =YES;
        queue = [[ASINetworkQueue alloc]init];
        SAFE_ARC_AUTORELEASE(queue);
        [queue setMaxConcurrentOperationCount:1];
        [queue setShowAccurateProgress:YES];
        [queue setUserInfo:@{@"model":self}];
        [queue setDelegate:self];
        [queue setQueueDidFinishSelector:@selector(queueDidFinished:)];
    }
    return self;
}
- (id)initWithDictionary:(NSDictionary *)dict
{
    if([self init])
    {
        NSArray *keys = [dict allKeys];
        for(NSString *key in keys)
        {
            [self setValue:dict[key] forKey:key];
        }
    }
    return self;
}
- (NSOperation *)getOperationWithDelegate:(NSObject *)delegateObject
{
    if(_url!=nil && _url.length>0)
    {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:_url]];
        [request setTimeOutSeconds:30.f];
        [request setDownloadProgressDelegate:delegateObject];
        [request setDelegate:delegateObject];
        NSString *newDownloading = [kPathDownloading stringByAppendingPathComponent:_directory];
        NSString *newFinish = [kPathFinished stringByAppendingPathComponent:_directory];
        [KLFileManage createDirectory:newDownloading];
        [KLFileManage createDirectory:newFinish];
        [request setTemporaryFileDownloadPath:[newDownloading stringByAppendingPathComponent:_name]];
        [request setDownloadDestinationPath:[newFinish stringByAppendingPathComponent:_name]];
        [request setAllowResumeForFileDownloads:YES];
        return request;
    }
    return nil;
}
- (void)addOperation:(NSOperation*)operation
{
    if(_m3u8TS!=nil && [_m3u8TS containsObject:[[(ASIHTTPRequest *)operation url] absoluteString]])
        return;
    if(queue)
       [queue addOperation:operation];
}
- (void)startWithDelegate:(NSObject *)delegateObject
{
    [self addOperation:[self getOperationWithDelegate:delegateObject]];
    [queue go];
}
- (BOOL)writeToFile:(NSString *)filePath
{
    NSDictionary *desc = [self desc];
    return [desc writeToFile:filePath atomically:YES];
}
- (void)stop
{
    [queue cancelAllOperations];
}

- (void)queueDidFinished:(ASINetworkQueue *)queue
{
    if([_loadedByte intValue]>=[_totalByte intValue] || _status==TaskStatusFinished)
    {
        if([KLFileManage removeFileWithPath:[[kPathDownloading stringByAppendingPathComponent:_name] stringByAppendingPathExtension:kIndexSuffix]])
            if([KLFileManage saveFileWithPath:[[kPathFinished stringByAppendingPathComponent:_name] stringByAppendingPathExtension:kIndexSuffix] content:[self desc]])
                NSLog(@"删除&创建Info : %@" , _name);
    }
}
- (NSDictionary *)desc
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    Class class = [self class];
    while (class != objc_getClass("NSObject"))
    {
        unsigned int outCount;
        objc_property_t *propertys = class_copyPropertyList(class, &outCount);
        if(outCount>0)
            for (int i = 0; i<outCount ; i++)
            {
                NSString *var = [NSString stringWithCString:property_getName(propertys[i]) encoding:NSUTF8StringEncoding];
                if([self valueForKey:var])
                    [dictionary setObject:[self valueForKey:var] forKey:var];
            }
        free(propertys);
        class = [class superclass];
    }
    return dictionary;
}

- (void)setFinishTask:(NSString *)taskurl
{
    if(!_m3u8TS)
        _m3u8TS = [NSMutableArray array];
    [_m3u8TS addObject:taskurl];
}
@end