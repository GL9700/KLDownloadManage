//
//  KLDownloadManage.h
//  KLDownloadManage
//
//  Created by Glen on 14-2-13.
//  Copyright (c) 2014年 Glen. All rights reserved.
//
// **************************************************************************
//                                                            --- 注意 ---
//  a)  请于pch内定义宏名称
//          kPathDownloading : 用于指定下载过程中温家存放的根目录
//          kPathFinished : 用于指定下载完成后，文件存放的根目录
//          kIndexSuffix : 用于指定 Info 文件的后缀
//          <例>
//              #define kPathFinished [[NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Finished"]
//              #define kPathDownloading [[NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Downloading"]
//              #define kIndexSuffix @"INF"
//
//  b)  此下载需要配合ASI使用，请事先自行添加ASI至项目
//
// **************************************************************************
//
// KLDownloadManage 此类用于下载文件，并保存至指定目录
// 为保证项目能够在任何时候轻松调用，请在项目之初就调用初始化函数
// 在需要控制和显示的页面设置delegate
//
//                                                                             --- --- Ver 1.0 --- --- --- --- 2014-03-03 --- ---
// **************************************************************************

#import <Foundation/Foundation.h>
#import "KLModelBase.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "KLDMMacros.h"

@class KLDownloadManage;

@protocol KLDownloadManageDelegate <NSObject>

- (void)taskUpdateProgressWithModel:(KLModelBase *)model;
- (void)taskFinish:(KLModelBase *)model;
- (void)taskError:(KLModelBase *)model;

@end

@interface KLDownloadManage : NSObject <ASIProgressDelegate , ASIHTTPRequestDelegate>
{
    NSMutableArray *models; // <Model>
    NSMutableArray *finisheds; // <Model>
    BOOL isHeaderBytes;
}

//TaskType is SingleFile (mp4 , avi ... bala bala) or M3U8(index , ts1 , ts2 , ts3 ....);
//taskType defualt is SingleFile;
@property TaskType taskType;
@property (nonatomic , SAFE_ARC_WEAK_ASSIGN) id<KLDownloadManageDelegate> delegate;
@property Class modelClass;

/** 
 * 初始化
 * 此函数不会自动开始下载
 */
+ (id)sharedDownloadManageWithModelClass:(Class)modelClass;

/**
 * 获取当前下载列表
 */
- (NSArray *)getDownloadingList;

/**
 * 获取已完成列表
 */
- (NSArray *)getFinishedList;

/** 
 * 添加任务 : (KLModelBase)模型 : 自动开始 : 错误
 */
- (BOOL)addTask:(KLModelBase *)model autoStart:(BOOL)start error:(NSError *__autoreleasing *)error;

/**
 * 删除下载中任务 : (KLModelBase)模型 : 错误
 */
- (BOOL)removeDownloadingWithTask:(KLModelBase *)model error:(NSError *__autoreleasing *)error;

/** 
 * 删除完成的任务 : (KLModelBase)模型 : 错误
 */
- (BOOL)removeFinishedWithTask:(KLModelBase *)model error:(NSError *__autoreleasing *)error;

/** 
 * 开始任务 : (KLModelBase)模型 : 错误
 */
- (BOOL)startTaskWithModel:(KLModelBase *)model error:(NSError *__autoreleasing *)error;

/** 
 * 暂停任务 : (KLModelBase)模型 : 错误
 */
- (BOOL)pauseTaskWithModel:(KLModelBase *)model error:(NSError *__autoreleasing *)error;

/** 
 * 开始全部任务
 */
+ (void)startList:(Class)modelClass;
- (void)startList;
/** 
 * 停止全部任务
 */
+ (void)pauseList:(Class)modelClass;
- (void)pauseList;
@end