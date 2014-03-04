//
//  KLModelProtocal.h
//  KLDownloadManage
//
//  Created by Glen on 14-2-25.
//  Copyright (c) 2014年 Glen. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"

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
@property (nonatomic , strong) NSString *ident;
@property (nonatomic , strong) NSString *name;
@property (nonatomic , strong) NSString *url;
@property (nonatomic , strong) NSString *directory;
@property (nonatomic , strong) NSString *loadedByte;
@property (nonatomic , strong) NSString *totalByte;

@property (nonatomic , strong) NSString *m3u8IV;
@property (nonatomic , strong) NSString *m3u8METHOD;
@property (nonatomic , strong) KLModelBase *m3u8KEY;
@property (nonatomic , strong) NSMutableArray *m3u8TS;
@property TaskStatus status;
@property BOOL isFirstReceive;

- (id)initWithDictionary:(NSDictionary *)dict;
- (NSOperation *)getOperationWithDelegate:(NSObject *)delegateObject;
- (NSDictionary *)desc;
- (BOOL)writeToFile:(NSString *)filePath;
- (void)addOperation:(NSOperation*)operation;
- (void)startWithDelegate:(NSObject *)delegateObject;
- (void)stop;
- (void)setFinishTask:(NSString *)taskurl;

@end