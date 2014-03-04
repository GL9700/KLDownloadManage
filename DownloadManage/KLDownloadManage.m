//
//  KLDownloadManage.m
//  KLDownloadManage
//
//  Created by Glen on 14-2-13.
//  Copyright (c) 2014年 Glen. All rights reserved.
//
#import <objc/objc-runtime.h>
#import "KLDownloadManage.h"
#import "KLFileManage.h"
#import "KLM3U8.h"

static KLDownloadManage *instanceDM;
@implementation KLDownloadManage

+ (id)sharedDownloadManageWithModelClass:(Class)modelClass
{
    if(!instanceDM)
    {
        instanceDM = [[KLDownloadManage alloc]init];
        SAFE_ARC_AUTORELEASE(instanceDM);
        [instanceDM setModelClass:modelClass];
        [instanceDM initLists];
    }
    return instanceDM;
}

#pragma mark- init
- (void)initLists
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if(![fm fileExistsAtPath:kPathDownloading])
        [fm createDirectoryAtPath:kPathDownloading withIntermediateDirectories:YES attributes:nil error:nil];
    if(![fm fileExistsAtPath:kPathFinished])
        [fm createDirectoryAtPath:kPathFinished withIntermediateDirectories:YES attributes:nil error:nil];
    
    models = [self getConverModelsFromFiles:[KLFileManage getFilesPathWithFolder:kPathDownloading withSuffix:kIndexSuffix]];
    finisheds = [self getConverModelsFromFiles:[KLFileManage getFilesPathWithFolder:kPathFinished withSuffix:kIndexSuffix]];
}
- (NSMutableArray *)getConverModelsFromFiles:(NSArray *)files
{
    NSMutableArray *marray = [NSMutableArray array];
    for(NSString *path in files)
    {
        NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:path];
        id instance = [[_modelClass alloc]initWithDictionary:d];
        SAFE_ARC_AUTORELEASE(instance);
        if([instance taskType] == TaskType_SingleFile)
        {
            NSString *filepath = [[kPathDownloading stringByAppendingPathComponent:[instance directory]] stringByAppendingPathComponent:[path stringByDeletingPathExtension]];
            NSDictionary *attributes = [KLFileManage getFileAttributes:filepath];
            [instance setLoadedByte:attributes[@"NSFileSize"]];
        }
        [marray addObject:instance];
    }
    return marray;
}

#pragma mark- Action
- (BOOL)addTask:(KLModelBase *)model autoStart:(BOOL)start error:(NSError *__autoreleasing *)error
{
    for(KLModelBase* baseModel in models)
    {
        if([baseModel.name isEqualToString: model.name] && [baseModel.directory isEqualToString: baseModel.directory])
        {
            if (error !=NULL)
                *error = KDM_Error_TaskIsExist;
            return NO;
        }
    }
    [models addObject:model];
    if(start==YES)
        [model startWithDelegate:self];
    return YES;
}
- (BOOL)removeDownloadingWithTask:(KLModelBase *)model error:(NSError *__autoreleasing *)error
{
    if([models containsObject:model])
    {
        [self pauseTaskWithModel:model error:nil];
        [models removeObject:model];
        return YES;
    }
    if (error !=NULL)
        *error = KDM_Error_TaskNotFound;
    return NO;
}
- (BOOL)removeFinishedWithTask:(KLModelBase *)model error:(NSError *__autoreleasing *)error
{
    if([finisheds containsObject:model])
    {
        [finisheds removeObject:model];
        return YES;
    }
    if (error !=NULL)
        *error = KDM_Error_TaskNotFound;
    return NO;
}
- (void)requestStarted:(ASIHTTPRequest *)request
{
    KLModelBase *model = [request.queue userInfo][@"model"];
    [model setStatus:TaskStatusStandyBy];
    [KLFileManage saveFileWithPath:[[kPathDownloading stringByAppendingPathComponent:model.name] stringByAppendingPathExtension:kIndexSuffix]
                           content:[model desc]];
}
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    KLModelBase *model = [request.queue userInfo][@"model"];
    if (model.isFirstReceive == YES)
    {
        if(model.taskType == TaskType_SingleFile){
            [model setTotalByte:responseHeaders[@"Content-Length"]];
            model.isFirstReceive = NO;
        }
    }
    [model setStatus:TaskStatusStarted];
    [KLFileManage saveFileWithPath:[[kPathDownloading stringByAppendingPathComponent:model.name] stringByAppendingPathExtension:kIndexSuffix]
                           content:[model desc]];
    isHeaderBytes = YES;
}
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    if(isHeaderBytes == YES){
        isHeaderBytes = NO;
        return;
    }
    KLModelBase *model = [request.queue userInfo][@"model"];
    if(model.taskType == TaskType_SingleFile){
        long long ll = [model.loadedByte intValue]+bytes;
        [model setLoadedByte:[NSString stringWithFormat:@"%lld" , ll]];
        if(_delegate!=nil && [_delegate respondsToSelector:@selector(taskUpdateProgressWithModel:)] && model.taskType == TaskType_SingleFile)
            [_delegate taskUpdateProgressWithModel:model];
    }
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    KLModelBase *model = [request.queue userInfo][@"model"];
    if(model.taskType == TaskType_SingleFile)
    {
        [model setStatus:TaskStatusFinished];
        if(_delegate!=nil && [_delegate respondsToSelector:@selector(taskFinish:)])
            [_delegate taskFinish:model];
    }else{
        if([model.url isEqualToString:[request.url absoluteString]])
        {
            NSDictionary *dic = [KLM3U8 M3U8WithIndexPath:[[kPathFinished stringByAppendingPathComponent:model.directory] stringByAppendingPathComponent:model.name]];
            [self createM3U8DownloadWithDictionary:dic model:model];
            if (model.isFirstReceive == YES)
            {
                int total = [request.queue operationCount];
                [model setTotalByte:[NSString stringWithFormat:@"%d" , total]];
                model.loadedByte = @"0";
                model.isFirstReceive = NO;
            }
        }else
            [model setFinishTask:[request.url absoluteString]];
        model.loadedByte = [NSString stringWithFormat:@"%d" , [model.m3u8TS count]];
        if(_delegate!=nil && [_delegate respondsToSelector:@selector(taskUpdateProgressWithModel:)])
            [_delegate taskUpdateProgressWithModel:model];
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    KLModelBase *model = [request.queue userInfo][@"model"];
    [model setStatus:TaskStatusErrorPaused];
    [KLFileManage saveFileWithPath:[[kPathDownloading stringByAppendingPathComponent:model.name] stringByAppendingPathExtension:kIndexSuffix]
                           content:[model desc]];
    if(_delegate!=nil && [_delegate respondsToSelector:@selector(taskError:)])
        [_delegate taskError:model];
}

#pragma mark- M3U8
- (void)createM3U8DownloadWithDictionary:(NSDictionary *)dic model:(KLModelBase *)model
{
    KLModelBase *mbkey = [[KLModelBase alloc]initWithDictionary:@{
                                                                 @"name":@"key",
                                                                 @"url":[dic objectForKey:@"uri"],
                                                                 @"directory":model.directory}];
    [model addOperation:[mbkey getOperationWithDelegate:self]];
    SAFE_ARC_AUTORELEASE(mbkey);
    for(NSDictionary *tsdic in dic[@"ts"])
    {
        KLModelBase *tsmb = [[KLModelBase alloc] initWithDictionary:@{
                                                                    @"name":[tsdic[@"url"] lastPathComponent],
                                                                    @"url":[tsdic objectForKey:@"url"],
                                                                    @"directory":model.directory}];
        [model addOperation:[tsmb getOperationWithDelegate:self]];
        SAFE_ARC_AUTORELEASE(tsmb);
    }
}

#pragma interface
- (BOOL)startTaskWithModel:(KLModelBase *)model error:(NSError *__autoreleasing *)error
{
    BOOL hasError = NO;
    if([models containsObject:model])
    {
        switch (model.status) {
            case TaskStatusStarted:
                hasError = YES;
                if (error !=NULL)
                    *error =  KDM_Error_TaskIsRunning;
                break;
            case TaskStatusStandyBy:
            case TaskStatusPaused:
            case TaskStatusErrorPaused:
            case TaskStatusFinished:
                [model startWithDelegate:self];
                break;
        }
    }
    return !hasError;
}
- (BOOL)pauseTaskWithModel:(KLModelBase *)model error:(NSError *__autoreleasing *)error
{
    BOOL hasError = NO;
    if([models containsObject:model])
    {
        switch (model.status) {
            case TaskStatusStarted:
            case TaskStatusStandyBy:
                hasError = YES;
                if (error !=NULL)
                    *error =  KDM_Error_TaskIsPausing;
                break;
            case TaskStatusPaused:
            case TaskStatusErrorPaused:
                hasError = YES;
                if (error !=NULL)
                    *error =  KDM_Error_TaskIsPausing;
                break;
            case TaskStatusFinished:
                hasError = YES;
                if (error !=NULL)
                    *error =  KDM_Error_TaskIsFinished;
                break;
        }
    }
    return !hasError;
}
- (NSArray *)getDownloadingList
{
    return models;
}
- (NSArray *)getFinishedList
{
    return finisheds;
}
+ (void)startList:(Class)modelClass;
{
    if(!instanceDM)
       [self sharedDownloadManageWithModelClass:modelClass];
    [instanceDM startList];
}
- (void)startList
{
    for(KLModelBase *mb in models)
    {
        [mb startWithDelegate:self];
    }
}
+ (void)pauseList:(Class)modelClass;
{
    if(!instanceDM)
        [self sharedDownloadManageWithModelClass:modelClass];
    [instanceDM pauseList];
}
- (void)pauseList
{
    for(KLModelBase *mb in models)
    {
        [mb stop];
    }
}
@end