//
//  analytics.m
//  analytics
//
//
//  Copyright (c) 2016年 tendcloud. All rights reserved.
//

#import <UMAnalytics/MobClick.h>

#import "UMAnalyticsModule.h"

@implementation UMAnalyticsModule

static UMAnalyticsModule *umengHyhrid = nil;

+ (BOOL)execute:(NSString *)parameters webView:(id)webView {
    NSString *prefix = @"umanalytics";
    if ([parameters hasPrefix:prefix]) {
        if (nil == umengHyhrid) {
            umengHyhrid = [[UMAnalyticsModule alloc] init];
        }
        NSString *str = [parameters substringFromIndex:prefix.length + 1];
        NSDictionary *dic = [self jsonToDictionary:str];
        NSString *functionName = [dic objectForKey:@"functionName"];
        NSArray *args = [dic objectForKey:@"arguments"];
        
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:", functionName]);
        
        if ([functionName isEqualToString:@"getDeviceId"]) {
            [umengHyhrid getDeviceId:args webView:webView];
        }else if ([functionName isEqualToString:@"getPreProperties"])
        {
            [umengHyhrid getPreProperties:args webView:webView];
        }else{
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

- (void)getDeviceId:(NSArray *)arguments webView:(id)webView {
    NSString *arg0 = [arguments objectAtIndex:0];
    if (arg0 == nil || [arg0 isKindOfClass:[NSNull class]] || arg0.length == 0) {
        return;
    }
    
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *callBack = [NSString stringWithFormat:@"%@('%@')", arg0, deviceId];
    
    if ([webView isKindOfClass:[UIWebView class]]) {
        [webView stringByEvaluatingJavaScriptFromString:callBack];
    } else if ([webView isKindOfClass:[WKWebView class]]) {
        [webView evaluateJavaScript:callBack completionHandler:nil];
    }
    
    
    
}


- (void)onEvent:(NSArray *)arguments {
    NSString *eventId = [arguments objectAtIndex:0];
    if (eventId == nil || [eventId isKindOfClass:[NSNull class]]) {
        return;
    }
    [MobClick event:eventId];
}

- (void)onEventWithLabel:(NSArray *)arguments {
    NSString *eventId = [arguments objectAtIndex:0];
    if (eventId == nil || [eventId isKindOfClass:[NSNull class]]) {
        return;
    }
    NSString *eventLabel = [arguments objectAtIndex:1];
    if ([eventLabel isKindOfClass:[NSNull class]]) {
        eventLabel = nil;
    }
    [MobClick event:eventId label:eventLabel];
}

- (void)onEventWithParameters:(NSArray *)arguments {
    NSString *eventId = [arguments objectAtIndex:0];
    if (eventId == nil || [eventId isKindOfClass:[NSNull class]]) {
        return;
    }
    NSDictionary *parameters = [arguments objectAtIndex:1];
    if (parameters == nil && [parameters isKindOfClass:[NSNull class]]) {
        parameters = nil;
    }
    [MobClick event:eventId attributes:parameters];
}

- (void)onEventWithCounter:(NSArray *)arguments {
    NSString *eventId = [arguments objectAtIndex:0];
    if (eventId == nil || [eventId isKindOfClass:[NSNull class]]) {
        return;
    }
    NSDictionary *parameters = [arguments objectAtIndex:1];
    if (parameters == nil && [parameters isKindOfClass:[NSNull class]]) {
        parameters = nil;
    }
    NSString *eventNum = [arguments objectAtIndex:2];
    if (eventNum == nil && [eventNum isKindOfClass:[NSNull class]]) {
        eventNum = nil;
    }
    int num = [eventNum intValue];
    [MobClick event:eventId attributes:parameters counter:num];
}

- (void)onPageBegin:(NSArray *)arguments {
    NSString *pageName = [arguments objectAtIndex:0];
    if (pageName == nil || [pageName isKindOfClass:[NSNull class]]) {
        return;
    }
    [MobClick beginLogPageView:pageName];
}

- (void)onPageEnd:(NSArray *)arguments {
    NSString *pageName = [arguments objectAtIndex:0];
    if (pageName == nil || [pageName isKindOfClass:[NSNull class]]) {
        return;
    }
    [MobClick endLogPageView:pageName];
}


- (void)profileSignInWithPUID:(NSArray *)arguments {
    NSString *puid = [arguments objectAtIndex:0];
    if (puid == nil || [puid isKindOfClass:[NSNull class]]) {
        return;
    }
    [MobClick profileSignInWithPUID:puid];
}

- (void)profileSignInWithPUIDWithProvider:(NSArray *)arguments {
    NSString *provider = [arguments objectAtIndex:0];
    if (provider == nil && [provider isKindOfClass:[NSNull class]]) {
        provider = nil;
    }
    NSString *puid = [arguments objectAtIndex:1];
    if (puid == nil || [puid isKindOfClass:[NSNull class]]) {
        return;
    }
    
    [MobClick profileSignInWithPUID:puid provider:provider];
}

- (void)profileSignOff:(NSArray *)arguments {
    
    [MobClick profileSignOff];
}



- (void)registerPreProperties:(NSArray *)arguments {
    NSDictionary *property = [arguments objectAtIndex:0];
    [MobClick registerPreProperties:property];
}

- (void)unregisterPreProperty:(NSArray *)arguments {
    NSString *propertyName = [arguments objectAtIndex:0];
    if (propertyName == nil || [propertyName isKindOfClass:[NSNull class]]) {
        return;
    }
    [MobClick unregisterPreProperty:propertyName];
}

- (void)getPreProperties:(NSArray *)arguments  webView:(id)webView {
    
    NSString *jsonString = nil;
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[MobClick getPreProperties]
                                                       options:kNilOptions //TODO: NSJSONWritingPrettyPrinted  // kNilOptions
                                                         error:&error];
    if ([jsonData length] && (error == nil))
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] ;
    }else{
        jsonString=@"";
    }
    
    NSString *callBack = [NSString stringWithFormat:@"callback('%@')",jsonString];
    
    if ([webView isKindOfClass:[UIWebView class]]) {
        [webView stringByEvaluatingJavaScriptFromString:callBack];
    } else if ([webView isKindOfClass:[WKWebView class]]) {
        [webView evaluateJavaScript:callBack completionHandler:nil];
    }
    
}

- (void)clearPreProperties:(NSArray *)arguments {
    [MobClick clearPreProperties];
}

- (void)setFirstLaunchEvent:(NSArray *)arguments {
    NSArray *eventList = [arguments objectAtIndex:0];
    [MobClick setFirstLaunchEvent:eventList];
}

@end
