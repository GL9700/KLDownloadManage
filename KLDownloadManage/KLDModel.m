//
//  KLDModel.m
//  KLDownloadManage
//
//  Created by Glen on 14-2-18.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import "KLDModel.h"
#import <objc/objc-runtime.h>

@implementation KLDModel
@synthesize fileDirectory, fileName  , url , status , loadedByte , totalByte , isFirstReceive , taskType;
- (id)initWithTaskWithURL:(NSString *)furl filename:(NSString *)filename type:(TaskType)type
{
    if((self = [super init]))
    {
        isFirstReceive = YES;
        self.titleName =filename;
        self.fileName = [furl lastPathComponent];
        self.url = furl;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)info
{
    if((self = [super init]))
    {
        
    }
    return self;
}

- (NSDictionary *)desc
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int outCount;
    objc_property_t *ps = class_copyPropertyList([self class], &outCount);
    for(int i = 0 ;i<outCount;i++)
    {
        NSString *key = [NSString stringWithCString:property_getName(ps[i]) encoding:NSUTF8StringEncoding];
        id value = [self valueForKey:key];
        if(value)
            [dic setObject:value forKey:key];
    }
    free(ps);
    return dic;
}
@end
