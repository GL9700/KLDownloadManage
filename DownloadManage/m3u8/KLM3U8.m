//
//  KLM3U8.m
//  KLDownloadManage
//
//  Created by Glen on 14-2-24.
//  Copyright (c) 2014年 Glen. All rights reserved.
//

#import "KLM3U8.h"
#import "KLEXTxKey.h"
#import "KLEXTINF.h"
#import "KLDMMacros.h"
@interface NSString(M3U8)
- (NSString *)subStringFrom:(NSString *)fromStr to:(NSString *)toStr;
@end

@implementation KLM3U8
+ (NSDictionary *)M3U8WithIndexPath:(NSString *)string
{
    NSMutableArray *ts = [NSMutableArray array];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSError *error = nil;
    NSString *m3u8Str = [NSString stringWithContentsOfFile:string encoding:NSUTF8StringEncoding error:&error];
    NSRange segmentRange = [m3u8Str rangeOfString:@"EXT-X-KEY"];
    if(segmentRange.location != NSNotFound)
    {
        KLEXTxKey *key = [[KLEXTxKey alloc]init];
        SAFE_ARC_AUTORELEASE(key);
        NSString *keyLine = [m3u8Str substringWithRange:[m3u8Str lineRangeForRange:segmentRange]];
        key.method = [keyLine subStringFrom:@"METHOD=" to:@",URI"];
        [dic setObject:key.method forKey:@"method"];
        key.URI = [keyLine subStringFrom:@"URI=\"" to:@"\",IV"];
        [dic setObject:key.URI forKey:@"uri"];
        NSRange range = [keyLine rangeOfString:@"IV="];
        key.iv = [keyLine substringFromIndex:range.location+range.length];
        [dic setObject:key.iv forKey:@"iv"];
    }
    segmentRange =[m3u8Str rangeOfString:@"EXTINF:"];
    KLEXTINF *inf = [[KLEXTINF alloc]init];
    SAFE_ARC_AUTORELEASE(inf);
    while (segmentRange.location != NSNotFound)
    {
        m3u8Str =[m3u8Str substringFromIndex:segmentRange.location+segmentRange.length-1];
        [inf setDuration:[m3u8Str subStringFrom:@":" to:@","]];
        NSRange range1 = [m3u8Str rangeOfString:@"http"];
        NSRange range2 = [m3u8Str rangeOfString:@".ts"];
        [inf setURL:[m3u8Str substringWithRange:NSMakeRange(range1.location, range2.location-range1.location+range2.length)]];
        [ts addObject:[NSDictionary dictionaryWithObjectsAndKeys:inf.duration,@"duration" , inf.URL , @"url",nil]];
        segmentRange =  [m3u8Str rangeOfString:@"EXTINF:"];
    }
    [dic setObject:ts forKey:@"ts"];
    return dic;
}
@end



@implementation NSString(M3U8)
- (NSString *)subStringFrom:(NSString *)fromStr to:(NSString *)toStr
{
    NSRange range1 = [self rangeOfString:fromStr];
    NSRange range2 = [self rangeOfString:toStr];
    return [self substringWithRange:NSMakeRange(range1.location+range1.length, range2.location-range1.length-range1.location)];
}
@end
