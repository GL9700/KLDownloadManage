//
//  KLModelProtocal.h
//  KLDownloadManage
//
//  Created by Glen on 14-2-17.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@protocol KLModelProtocal <NSObject>

@required
@property TaskType taskType;
@property TaskStatus status;
@property BOOL isFirstReceive;
@property (nonatomic , strong) NSString *url;
@property (nonatomic , strong) NSString *fileDirectory;
@property (nonatomic , strong) NSString *fileName;
@property (nonatomic , strong) NSString *loadedByte;
@property (nonatomic , strong) NSString *totalByte;

- (id)initWithTaskWithURL:(NSString *)furl filename:(NSString *)filename type:(TaskType)type;
- (id)initWithDictionary:(NSDictionary *)info;
- (NSDictionary *)desc;

@end
