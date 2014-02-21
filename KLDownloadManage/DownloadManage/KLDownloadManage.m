//
//  KLDownloadManage.m
//  KLDownloadManage
//
//  Created by Glen on 14-2-13.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import "KLDownloadManage.h"
#import "KLDModel.h"
#import "KLFileManage.h"
static KLDownloadManage *instanceDM;
@implementation KLDownloadManage

- (id)init
{
    if((self = [super init]))
    {
        [self initLists];
    }
    return self;
}
+ (id)sharedDownloadManage
{
    if(!instanceDM)
        instanceDM = [[KLDownloadManage alloc]init];
    return instanceDM;
}

- (BOOL)addTask:(id<KLModelProtocal>)model error:(NSError **)error
{
    NSOperationQueue *modelQueue = [self queueWithSingleModel:model];
    if(downArray)
    {
        [(ASINetworkQueue *)modelQueue setUserInfo:@{@"ident":[model fileName]}];
        if(![self existQueue:modelQueue])
        {
            [(NSObject *)model addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
            [self addModelRequestToListWithQueue:modelQueue];
            return YES;
        }else{
            *error = KDM_Error_01;
        }
    }else{
        *error = KDM_Error_02;
    }
    return NO;
}

- (BOOL)startTaskWithModel:(id<KLModelProtocal>)model
{
    return NO;
}
- (BOOL)stopTaskWithModel:(id<KLModelProtocal>)model
{
    [model setStatus:TaskStatusStarted];
    return YES;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    for(ASINetworkQueue *q in downArray)
        for(ASIHTTPRequest *r in [q operations])
            if(r.userInfo[@"model"] == object)
                [self saveIndex:q];
}

- (BOOL)startList
{
    if ([downArray count]>0){
        for(int i = 0 ; i<[downArray count] ; i++){
            if(currentRunProcessCount == 0){
                ASINetworkQueue *q = downArray[i];
                [q go];
                currentRunProcessCount++;
                if(_isSingleProcess == YES)
                    break;
            }
        }
    }
    return NO;
}
- (BOOL)stopList
{
    for(ASINetworkQueue *q in downArray)
        for(ASIHTTPRequest *r in [q operations])
            [(id<KLModelProtocal>)q.userInfo[@"model"] setStatus:TaskStatusPaused];
    return NO;
}

- (void)initLists
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:kPathDownloading])
        [fm createDirectoryAtPath:kPathDownloading withIntermediateDirectories:YES attributes:nil error:nil];
    if(![fm fileExistsAtPath:kPathFinished])
        [fm createDirectoryAtPath:kPathFinished withIntermediateDirectories:YES attributes:nil error:nil];
    downArray = [[NSMutableArray alloc]init];
    finishArray = [[NSMutableArray alloc]init];
}
- (NSArray *)getFinishedList
{
    return finishArray;
}
- (NSArray *)getDownloadingList
{
    return downArray;
}
- (int)getRunningCount
{
    return currentRunProcessCount;
}
/** 遍历文件后进行匹配，续传用 */
- (void)findandConvertFiles:(NSString *)path to:(NSMutableArray *)mArr
{
    
}
/** 查找此任务(组)是否已经存在于 download List 中 */
- (BOOL)existQueue:(NSOperationQueue *)queue
{
    BOOL exist = NO;
    for (NSOperationQueue *q in downArray) {
        if([((ASINetworkQueue *)q).userInfo[@"ident"] isEqualToString:((ASINetworkQueue *)queue).userInfo[@"ident"]])
        {
            exist = YES;
            break;
        }
    }
    return exist;
}
/** 将model转化成Operation */
- (NSOperation *)convertOperationFromModel:(id<KLModelProtocal>)model
{
    ASIHTTPRequest *request = (ASIHTTPRequest *)[self createOperationAndConfigModel:model];
    return request;
}
/** 任务添加到Queue */
- (NSOperationQueue *)queueWithSingleModel:(id<KLModelProtocal>)model
{
    NSOperationQueue *q = [self createQueueAndConfig];
    ASIHTTPRequest *request = (ASIHTTPRequest *)[self convertOperationFromModel:model];
    [q addOperation:request];
    [(ASINetworkQueue *)q go];
    return q;
}
- (NSOperationQueue *)queueWithMultipleModel:(NSArray *)models  withDirectory:(NSString *)dir
{
    NSOperationQueue *q = [self createQueueAndConfig];
    for(id<KLModelProtocal> model in models)
    {
        [model setFileDirectory:dir];
        [q addOperation:[self convertOperationFromModel:model]];
    }
    [(ASINetworkQueue *)q go];
    return q;
}
/** 创建 Operation & Queue */
- (NSOperation *)createOperationAndConfigModel:(id<KLModelProtocal>)model
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:model.url]];
    [request setTimeOutSeconds:30.f];
    [request setDownloadProgressDelegate:self];
    [request setDelegate:self];
    [request setUserInfo:@{@"model":model}];
    if([model fileDirectory] == nil)
    {
        [request setTemporaryFileDownloadPath:[kPathDownloading stringByAppendingPathComponent:model.fileName]];
        [request setDownloadDestinationPath:[kPathFinished stringByAppendingPathComponent:model.fileName]];
    }
    else
    {
        [request setTemporaryFileDownloadPath:[[kPathDownloading stringByAppendingPathComponent:model.fileDirectory] stringByAppendingPathComponent:model.fileName]];
        [request setDownloadDestinationPath:[[kPathFinished stringByAppendingPathComponent:model.fileDirectory] stringByAppendingPathComponent:model.fileName]];
    }
    [request setAllowResumeForFileDownloads:YES];
    return request;
}
- (NSOperationQueue *)createQueueAndConfig
{
    ASINetworkQueue *queue = [[ASINetworkQueue alloc]init];
    [queue setShowAccurateProgress:YES];
    [queue setMaxConcurrentOperationCount:1];
    [queue setQueueDidFinishSelector:@selector(queueDidFinished:)];
    [queue setDelegate:self];
    return queue;
}

/**将任务组添加进下载列表 择时下载*/
- (void)addModelRequestToListWithQueue:(NSOperationQueue *)queue
{
    [downArray addObject:queue];
    [self saveIndex:queue];
}

/** 创建/修改 索引 */
- (void)saveIndex:(NSOperationQueue*)queue
{
    if(queue.operationCount>0)
    {
        NSMutableArray *array = [NSMutableArray array];
        for (int i =0;i<queue.operationCount;i++)
        {
            ASIHTTPRequest *request = queue.operations[i];
            if(request.userInfo[@"model"])
            {
                id<KLModelProtocal> model = request.userInfo[@"model"];
                [array addObject:[model desc]];
            }
        }
        NSString *indexFilePath = [[kPathDownloading stringByAppendingPathComponent:((ASINetworkQueue *)queue).userInfo[@"ident"]]stringByAppendingPathExtension:kDownloadIndexSuffix];
        if([array writeToFile:indexFilePath atomically:YES])
        {
            NSLog(@"文件写入成功 : %@" , indexFilePath);
        }else{
            assert(0);
        }
    }
}

#pragma ASIHTTPRequestDelegate ASINetworkQueueDelegate
- (void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"%s" , __func__);
    [(id<KLModelProtocal>)request.userInfo[@"model"] setStatus:TaskStatusStarted];
}
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    NSLog(@"%s" , __func__);
    id<KLModelProtocal> model = request.userInfo[@"model"];
    long long d = 0;
    if([model loadedByte])
        d = atoll([[model loadedByte] UTF8String]);
    long long t = atoll([[model totalByte] UTF8String]);
    t=t==0?1:t;
    long long l = bytes+d;
    float p = ((float)l/t);
    if(_delegate ==nil && [_delegate respondsToSelector:@selector(updateProgress:progress:)])
    {
        [_delegate updateProgress:model progress:p];
    }
    [model setLoadedByte:[NSString stringWithFormat:@"%lld" , l]];
}
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    id<KLModelProtocal> model = request.userInfo[@"model"];
    if([model isFirstReceive] == YES || atoll([[model totalByte] UTF8String]) == 0)
    {
        [model setIsFirstReceive:NO];
        [model setTotalByte:request.responseHeaders[@"Content-Length"]];
    }
    NSLog(@"%s" , __func__);
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%s" , __func__);
    [(id<KLModelProtocal>)request.userInfo[@"model"] setStatus:TaskStatusFinished];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"%s" , __func__);
    [(id<KLModelProtocal>)request.userInfo[@"model"] setStatus:TaskStatusErrorPaused];
}
- (void)queueDidFinished:(ASINetworkQueue *)queue
{
    NSString *indexFilePath = [[kPathDownloading stringByAppendingPathComponent:((ASINetworkQueue *)queue).userInfo[@"ident"]]stringByAppendingPathExtension:kDownloadIndexSuffix];
    NSArray *queueInfo = [NSArray arrayWithContentsOfFile:indexFilePath];
    [KLFileManage removeFileWithPath:indexFilePath];
}

@end