//
//  UMPushModule.m
//  UMComponent
//
//  Created by wyq.Cloudayc on 11/09/2017.
//  Copyright © 2017 Umeng. All rights reserved.
//

#import "UMPushModule.h"
#import <UMPush/UMessage.h>

@implementation UMPushModule

static UMPushModule *umengHyhrid = nil;

+ (BOOL)execute:(NSString *)parameters webView:(UIWebView *)webView {
    NSString *prefix = @"umpush";
    if ([parameters hasPrefix:prefix]) {
        if (nil == umengHyhrid) {
            umengHyhrid = [[UMPushModule alloc] init];
        }
        NSString *str = [parameters substringFromIndex:prefix.length + 1];
        NSDictionary *dic = [self jsonToDictionary:str];
        NSString *functionName = [dic objectForKey:@"functionName"];
        NSArray *args = [dic objectForKey:@"arguments"];
        if ([functionName isEqualToString:@"getDeviceId"]) {
            [umengHyhrid getDeviceId:args webView:webView];
        } else {
            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:", functionName]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([umengHyhrid respondsToSelector:selector]) {
                [umengHyhrid performSelector:selector withObject:args];
            }
#pragma clang diagnostic pop
        }
        return YES;
    }
    
    return NO;
}

+ (NSDictionary *)jsonToDictionary:(NSString *)jsonStr {
    if (jsonStr) {
        NSError* error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (error == nil && [object isKindOfClass:[NSDictionary class]]) {
            return object;
        }
    }
    
    return nil;
}

- (void)getDeviceId:(NSArray *)arguments webView:(UIWebView *)webView {
    NSString *arg0 = [arguments objectAtIndex:0];
    if (arg0 == nil || [arg0 isKindOfClass:[NSNull class]] || arg0.length == 0) {
        return;
    }
    
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *callBack = [NSString stringWithFormat:@"%@('%@')", arg0, deviceId];
    [webView stringByEvaluatingJavaScriptFromString:callBack];
    
}


@end
