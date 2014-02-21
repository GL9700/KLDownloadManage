//
//  KLDownloadManage.h
//  KLDownloadManage
//
//  Created by Glen on 14-2-13.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLModelProtocal.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

#define kPathFinished [[NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Finished"]
#define kPathDownloading [[NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Downloading"]
#define kDownloadIndexSuffix @"INF"

#define KDM_Error_01 [NSError errorWithDomain:@" Task has existed " code:01 userInfo:nil]
#define KDM_Error_02 [NSError errorWithDomain:@" Download List not Created " code:02 userInfo:nil]
#define KDM_Error_03 [NSError errorWithDomain:@"  " code:03 userInfo:nil]
#define KDM_Error_04 [NSError errorWithDomain:@"  " code:04 userInfo:nil]
#define KDM_Error_05 [NSError errorWithDomain:@"  " code:05 userInfo:nil]
#define KDM_Error_06 [NSError errorWithDomain:@"  " code:06 userInfo:nil]

@class KLDownloadManage;
@protocol KLDownloadManageDelegate <NSObject>
- (void)updateProgress:(id<KLModelProtocal>)model progress:(float)progressFloat;
@end

@interface KLDownloadManage : NSObject <ASIProgressDelegate , ASIHTTPRequestDelegate>
{
    ASINetworkQueue *downloadQueue; // <operation>
    NSMutableArray *downArray; // <OperationQueue>
    NSMutableArray *finishArray; // <Model>
    int currentRunProcessCount;
}

// Multiple Mission ; defualt is NO
@property BOOL isSingleProcess;

//TaskType is SingleFile (mp4 , avi ... bala bala) or M3U8(index , ts1 , ts2 , ts3 ....);
//taskType defualt is SingleFile;
@property TaskType taskType UNAVAILABLE_ATTRIBUTE;

@property (nonatomic , assign) id<KLDownloadManageDelegate> delegate;

+ (id)sharedDownloadManage;

/** 获取信息 */
- (NSArray *)getDownloadingList;
- (NSArray *)getFinishedList;
- (int)getRunningCount;

/** 添加任务 */
- (BOOL)addTask:(id<KLModelProtocal>)model error:(NSError **)error;
//- (BOOL)addTaskWithURL:(NSURL *)taskURL fileName:(NSString *)name folderName:(NSString *)folder taskType:(TaskType *)type error:(NSError **)error;

/** 任务 开始 停止 */
- (BOOL)startTaskWithModel:(id<KLModelProtocal>)model;
- (BOOL)stopTaskWithModel:(id<KLModelProtocal>)model;

/** 全部 开始 停止 */
- (BOOL)startList;
- (BOOL)stopList;

@end