//
//  UMCommonModule.m
//  Hybrid_Component
//
//  Created by wangfei on 2017/10/11.
//  Copyright © 2017年 wangkai. All rights reserved.
//

#import "UMCommonModule.h"

@implementation UMCommonModule
+ (void)initWithAppkey:(NSString *)appkey channel:(NSString *)channel
{
    SEL sel = NSSelectorFromString(@"setWraperType:wrapperVersion:");
    if ([UMConfigure respondsToSelector:sel]) {
        [UMConfigure performSelector:sel withObject:@"hybird" withObject:@"1.0"];
    }
    [UMConfigure initWithAppkey:appkey channel:channel];
}
@end
