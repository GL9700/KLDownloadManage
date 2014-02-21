//
//  KLDownloadManageTests.m
//  KLDownloadManageTests
//
//  Created by Glen on 14-2-13.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KLDModel.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
@interface KLDownloadManageTests : XCTestCase

@end

@implementation KLDownloadManageTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]init];
    ASINetworkQueue *queue = [ASINetworkQueue queue];
    [queue addOperation:request];
    NSLog(@"%@" , [queue operations]);
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
