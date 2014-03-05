//
//  KLModelProtocal.h
//  KLDownloadManage
//
//  Created by Glen on 14-2-25.
//  Copyright (c) 2014年 Glen. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"

typedef enum
{
    TaskStatusStandyBy = 0,
    TaskStatusStarted,
    TaskStatusPaused,
    TaskStatusErrorPaused,
    TaskStatusFinished
}TaskStatus;

typedef enum {
    TaskType_SingleFile,
    TaskType_M3U8
}TaskType;

@interface KLModelBase : NSObject < ASIHTTPRequestDelegate , ASIProgressDelegate>
{
    ASINetworkQueue *queue;
}

@property TaskType taskType;
@property (nonatomic , strong) NSString *dm_ident;
@property (nonatomic , strong) NSString *dm_name;
@property (nonatomic , strong) NSString *dm_url;
@property (nonatomic , strong) NSString *dm_directory;
@property (nonatomic , strong) NSString *dm_loadedByte;
@property (nonatomic , strong) NSString *dm_totalByte;

@property (nonatomic , strong) NSString *dm_m3u8IV;
@property (nonatomic , strong) NSString *dm_m3u8METHOD;
@property (nonatomic , strong) KLModelBase *dm_m3u8KEY;
@property (nonatomic , strong) NSMutableArray *dm_m3u8TS;
@property TaskStatus dm_status;
@property BOOL dm_isFirstReceive;

- (id)initWithDictionary:(NSDictionary *)dict;
- (NSOperation *)getOperationWithDelegate:(NSObject *)delegateObject;
- (NSDictionary *)desc;
- (BOOL)writeToFile:(NSString *)filePath;
- (void)addOperation:(NSOperation*)operation;
- (void)startWithDelegate:(NSObject *)delegateObject;
- (void)stop;
- (void)addFinishTS:(NSString *)tsurl;

@end