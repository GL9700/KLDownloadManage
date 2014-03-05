//
//  KLDownloadManage.m
//
//  Created by Glen on 14-2-13.
//  Copyright (c) 2014年 Glen. All rights reserved.
//
#import "KLDownloadManage.h"
#import "KLFileManage.h"
#import "KLM3U8.h"
#import "ASIHTTPRequest.h"

static KLDownloadManage *instanceDM;
@implementation KLDownloadManage

+ (id)sharedDownloadManageWithModelClass:(Class)modelClass
{
    if(!instanceDM)
    {
        instanceDM = [[KLDownloadManage alloc]init];
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
    
    loads = SAFE_ARC_RETAIN([self getConverModelsFromFiles:[KLFileManage getFilesPathWithFolder:kPathDownloading withSuffix:kIndexSuffix]]);
    finisheds = SAFE_ARC_RETAIN([self getConverModelsFromFiles:[KLFileManage getFilesPathWithFolder:kPathFinished withSuffix:kIndexSuffix]]);
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
            NSString *filepath = [[kPathDownloading stringByAppendingPathComponent:[instance dm_directory]] stringByAppendingPathComponent:[path stringByDeletingPathExtension]];
            NSDictionary *attributes = [KLFileManage getFileAttributes:filepath];
            [instance setDm_loadedByte:attributes[@"NSFileSize"]];
        }
        [marray addObject:instance];
    }
    return marray;
}

#pragma mark- Action
- (BOOL)addTask:(KLModelBase *)model autoStart:(BOOL)start error:(NSError *__autoreleasing *)error
{
    for(KLModelBase* baseModel in loads)
    {
        if([baseModel.dm_name isEqualToString: model.dm_name] && [baseModel.dm_directory isEqualToString: baseModel.dm_directory])
        {
            if (error !=NULL)
                *error = KDM_Error_TaskIsExist;
            return NO;
        }
    }
    [loads addObject:model];
    if(start==YES)
        [model startWithDelegate:self];
    return YES;
}
- (BOOL)removeDownloadingWithTask:(KLModelBase *)model error:(NSError *__autoreleasing *)error
{
    if([loads containsObject:model])
    {
        [self pauseTaskWithModel:model error:nil];
        [loads removeObject:model];
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
    [model setDm_status:TaskStatusStandyBy];
    [KLFileManage saveFileWithPath:[[kPathDownloading stringByAppendingPathComponent:model.dm_name] stringByAppendingPathExtension:kIndexSuffix]
                           content:[model desc]];
}
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    KLModelBase *model = [request.queue userInfo][@"model"];
    if (model.dm_isFirstReceive == YES)
    {
        if(model.taskType == TaskType_SingleFile){
            [model setDm_totalByte:responseHeaders[@"Content-Length"]];
            model.dm_isFirstReceive = NO;
        }
    }
    [model setDm_status:TaskStatusStarted];
    [KLFileManage saveFileWithPath:[[kPathDownloading stringByAppendingPathComponent:model.dm_name] stringByAppendingPathExtension:kIndexSuffix]
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
        long long ll = [model.dm_loadedByte intValue]+bytes;
        [model setDm_loadedByte:[NSString stringWithFormat:@"%lld" , ll]];
        if(_delegate!=nil && [_delegate respondsToSelector:@selector(taskUpdateProgressWithModel:)] && model.taskType == TaskType_SingleFile)
            [_delegate taskUpdateProgressWithModel:model];
    }
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    KLModelBase *model = [request.queue userInfo][@"model"];
    if(model.taskType == TaskType_SingleFile)
    {
        [model setDm_status:TaskStatusFinished];
        if(_delegate!=nil && [_delegate respondsToSelector:@selector(taskFinish:)])
            [_delegate taskFinish:model];
    }else{
        if([model.dm_url isEqualToString:[request.url absoluteString]])
        {
            NSDictionary *dic = [KLM3U8 M3U8WithIndexPath:[[kPathFinished stringByAppendingPathComponent:model.dm_directory] stringByAppendingPathComponent:model.dm_name]];
            [self createM3U8DownloadWithDictionary:dic model:model];
            if (model.dm_isFirstReceive == YES)
            {
                int total = [request.queue operationCount];
                [model setDm_totalByte:[NSString stringWithFormat:@"%d" , total]];
                model.dm_loadedByte = @"0";
                model.dm_isFirstReceive = NO;
            }
        }else
            [model addFinishTS:[request.url absoluteString]];
        model.dm_loadedByte = [NSString stringWithFormat:@"%d" , [model.dm_m3u8TS count]];
        if(_delegate!=nil && [_delegate respondsToSelector:@selector(taskUpdateProgressWithModel:)])
            [_delegate taskUpdateProgressWithModel:model];
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    KLModelBase *model = [request.queue userInfo][@"model"];
    [model setDm_status:TaskStatusErrorPaused];
    [KLFileManage saveFileWithPath:[[kPathDownloading stringByAppendingPathComponent:model.dm_name] stringByAppendingPathExtension:kIndexSuffix]
                           content:[model desc]];
    if(_delegate!=nil && [_delegate respondsToSelector:@selector(taskError:)])
        [_delegate taskError:model];
}

#pragma mark- M3U8
- (void)createM3U8DownloadWithDictionary:(NSDictionary *)dic model:(KLModelBase *)model
{
    KLModelBase *mbkey = [[KLModelBase alloc]initWithDictionary:@{
                                                                 @"dm_name":@"key",
                                                                 @"dm_url":[dic objectForKey:@"uri"],
                                                                 @"dm_directory":model.dm_directory}];
    [model addOperation:[mbkey getOperationWithDelegate:self]];
    SAFE_ARC_AUTORELEASE(mbkey);
    for(NSDictionary *tsdic in dic[@"ts"])
    {
        KLModelBase *tsmb = [[KLModelBase alloc] initWithDictionary:@{
                                                                    @"dm_name":[tsdic[@"url"] lastPathComponent],
                                                                    @"dm_url":[tsdic objectForKey:@"url"],
                                                                    @"dm_directory":model.dm_directory}];
        [model addOperation:[tsmb getOperationWithDelegate:self]];
        SAFE_ARC_AUTORELEASE(tsmb);
    }
}

#pragma interface
- (BOOL)startTaskWithModel:(KLModelBase *)model error:(NSError *__autoreleasing *)error
{
    BOOL hasError = NO;
    if([loads containsObject:model])
    {
        switch (model.dm_status) {
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
    if([loads containsObject:model])
    {
        switch (model.dm_status) {
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
    return loads;
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
    for(KLModelBase *mb in loads)
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
    for(KLModelBase *mb in loads)
    {
        [mb stop];
    }
}
@end