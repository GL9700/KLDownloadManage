//
//  KLDMMacros.h
//  AIKU
//
//  Created by Glen on 14-3-3.
//  Copyright (c) 2014年 koolearn. All rights reserved.
//

#if !defined(__clang__) || __clang_major__ < 3
    #ifndef __bridge
        #define __bridge
    #endif
    #ifndef __bridge_retain
        #define __bridge_retain
    #endif
    #ifndef __bridge_retained
        #define __bridge_retained
    #endif
    #ifndef __autoreleasing
        #define __autoreleasing
    #endif
    #ifndef __strong
        #define __strong
    #endif
    #ifndef __unsafe_unretained
        #define __unsafe_unretained
    #endif
    #ifndef __weak
        #define __weak
    #endif
#endif

#if __has_feature(objc_arc)
    #define SAFE_ARC_PROP_RETAIN strong
    #define SAFE_ARC_RETAIN(x) (x)
    #define SAFE_ARC_RELEASE(x)
    #define SAFE_ARC_AUTORELEASE(x) (x)
    #define SAFE_ARC_BLOCK_COPY(x) (x)
    #define SAFE_ARC_BLOCK_RELEASE(x)
    #define SAFE_ARC_SUPER_DEALLOC()
    #define SAFE_ARC_AUTORELEASE_POOL_START() @autoreleasepool {
    #define SAFE_ARC_AUTORELEASE_POOL_END() }
    #define SAFE_ARC_WEAK_ASSIGN weak
#else
    #define SAFE_ARC_PROP_RETAIN retain
    #define SAFE_ARC_RETAIN(x) ([(x) retain])
    #define SAFE_ARC_RELEASE(x) ([(x) release])
    #define SAFE_ARC_AUTORELEASE(x) ([(x) autorelease])
    #define SAFE_ARC_BLOCK_COPY(x) (Block_copy(x))
    #define SAFE_ARC_BLOCK_RELEASE(x) (Block_release(x))
    #define SAFE_ARC_SUPER_DEALLOC() ([super dealloc])
    #define SAFE_ARC_AUTORELEASE_POOL_START() NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    #define SAFE_ARC_AUTORELEASE_POOL_END() [pool release];
    #define SAFE_ARC_WEAK_ASSIGN assign
#endif


#define KDM_Error_TaskIsExist [NSError errorWithDomain:@" Task has existed " code:01 userInfo:nil]
#define KDM_Error_TaskNotFound [NSError errorWithDomain:@" Task not Found " code:02 userInfo:nil]
#define KDM_Error_TaskIsRunning [NSError errorWithDomain:@" Task has Running " code:11 userInfo:nil]
#define KDM_Error_TaskIsPausing [NSError errorWithDomain:@" Task has Pausing " code:12 userInfo:nil]
#define KDM_Error_TaskIsFinished [NSError errorWithDomain:@" Task has Finished " code:13 userInfo:nil]