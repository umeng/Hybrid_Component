//
//  analytics.m
//  analytics
//
//
//  Copyright (c) 2016年 tendcloud. All rights reserved.
//

#import <UMAnalytics/MobClick.h>
#import <UMAnalytics/MobClickGameAnalytics.h>
#import <UMAnalytics/DplusMobClick.h>

#import "UMAnalyticsModule.h"

@implementation UMAnalyticsModule

static UMAnalyticsModule *umengHyhrid = nil;

+ (BOOL)execute:(NSString *)parameters webView:(UIWebView *)webView {
    if ([parameters hasPrefix:@"umeng"]) {
        if (nil == umengHyhrid) {
            umengHyhrid = [[UMAnalyticsModule alloc] init];
        }
        NSString *str = [parameters substringFromIndex:6];
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
    [MobClickGameAnalytics profileSignInWithPUID:puid];
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
    
    [MobClickGameAnalytics profileSignInWithPUID:puid provider:provider];
}

- (void)profileSignOff:(NSArray *)arguments {
    
    [MobClickGameAnalytics profileSignOff];
}
//游戏统计
- (void)setUserLevelId:(NSArray *)arguments {
    NSString *level = [arguments objectAtIndex:0];
    if (level == nil || [level isKindOfClass:[NSNull class]]) {
        return;
    }
    int levelValue = [level intValue];
    [MobClickGameAnalytics setUserLevelId:levelValue];
}

- (void)startLevel:(NSArray *)arguments {
    NSString *level = [arguments objectAtIndex:0];
    if (level == nil || [level isKindOfClass:[NSNull class]]) {
        return;
    }
    [MobClickGameAnalytics startLevel:level];
}

- (void)finishLevel:(NSArray *)arguments {
    NSString *level = [arguments objectAtIndex:0];
    if (level == nil || [level isKindOfClass:[NSNull class]]) {
        return;
    }
    [MobClickGameAnalytics finishLevel:level];
}
- (void)failLevel:(NSArray *)arguments {
    NSString *level = [arguments objectAtIndex:0];
    if (level == nil || [level isKindOfClass:[NSNull class]]) {
        return;
    }
    [MobClickGameAnalytics failLevel:level];
}

- (void)exchange:(NSArray *)arguments {
    
    NSString *currencyAmount = [arguments objectAtIndex:0];
    if (currencyAmount == nil && [currencyAmount isKindOfClass:[NSNull class]]) {
        currencyAmount = nil;
    }
    NSString *currencyType = [arguments objectAtIndex:1];
    if (currencyType == nil && [currencyType isKindOfClass:[NSNull class]]) {
        currencyType = nil;
    }
    NSString *virtualAmount = [arguments objectAtIndex:2];
    if (virtualAmount == nil && [virtualAmount isKindOfClass:[NSNull class]]) {
        virtualAmount = nil;
    }
    NSString *channel = [arguments objectAtIndex:3];
    if (channel == nil && [channel isKindOfClass:[NSNull class]]) {
        channel = nil;
    }
    NSString *orderId = [arguments objectAtIndex:4];
    if (orderId == nil || [orderId isKindOfClass:[NSNull class]]) {
        return;
    }
    double currencyAmountDouble = [currencyAmount doubleValue];
    double virtualAmountDouble = [virtualAmount doubleValue];
    int channelInt = [channel intValue];
    [MobClickGameAnalytics exchange:orderId currencyAmount:currencyAmountDouble currencyType:currencyType virtualCurrencyAmount:virtualAmountDouble paychannel:channelInt];
}

- (void)pay:(NSArray *)arguments {
    NSString *cash = [arguments objectAtIndex:0];
    if (cash == nil || [cash isKindOfClass:[NSNull class]]) {
        return;
    }
    NSString *coin = [arguments objectAtIndex:1];
    if (coin == nil && [coin isKindOfClass:[NSNull class]]) {
        coin = nil;
    }
    NSString *source = [arguments objectAtIndex:2];
    if (source == nil && [source isKindOfClass:[NSNull class]]) {
        source = nil;
    }
    
    
    double cashDouble = [cash doubleValue];
    int sourceInt = [source doubleValue];
    double coinDouble = [coin doubleValue];
    [MobClickGameAnalytics pay:cashDouble source:sourceInt coin:coinDouble];
}

- (void)payWithItem:(NSArray *)arguments {
    NSString *cash = [arguments objectAtIndex:0];
    if (cash == nil || [cash isKindOfClass:[NSNull class]]) {
        return;
    }
    NSString *item = [arguments objectAtIndex:1];
    if (item == nil && [item isKindOfClass:[NSNull class]]) {
        item = nil;
    }
    NSString *amount = [arguments objectAtIndex:2];
    if (amount == nil && [amount isKindOfClass:[NSNull class]]) {
        amount = nil;
    }
    NSString *price = [arguments objectAtIndex:3];
    if (price == nil && [price isKindOfClass:[NSNull class]]) {
        price = nil;
    }
    NSString *source = [arguments objectAtIndex:4];
    if (source == nil && [source isKindOfClass:[NSNull class]]) {
        source = nil;
    }
    double cashDoule = [cash doubleValue];
    int sourceInt = [source intValue];
    int amountInt = [amount intValue];
    double priceDouble = [price doubleValue];
    [MobClickGameAnalytics pay:cashDoule source:sourceInt item:item amount:amountInt price:priceDouble];
}

- (void)buy:(NSArray *)arguments {
    NSString *item = [arguments objectAtIndex:0];
    if (item == nil || [item isKindOfClass:[NSNull class]]) {
        return;
    }
    NSString *amount = [arguments objectAtIndex:1];
    if (amount == nil && [amount isKindOfClass:[NSNull class]]) {
        amount = nil;
    }
    NSString *price = [arguments objectAtIndex:2];
    if (price == nil && [price isKindOfClass:[NSNull class]]) {
        price = nil;
    }
    
    int amountInt = [amount doubleValue];
    double priceDouble = [price doubleValue];
    [MobClickGameAnalytics buy:item amount:amountInt price:priceDouble];
}

- (void)use:(NSArray *)arguments {
    NSString *item = [arguments objectAtIndex:0];
    if (item == nil || [item isKindOfClass:[NSNull class]]) {
        return;
    }
    NSString *amount = [arguments objectAtIndex:1];
    if (amount == nil && [amount isKindOfClass:[NSNull class]]) {
        amount = nil;
    }
    NSString *price = [arguments objectAtIndex:2];
    if (price == nil && [price isKindOfClass:[NSNull class]]) {
        price = nil;
    }
    
    int amountInt = [amount doubleValue];
    double priceDouble = [price doubleValue];
    [MobClickGameAnalytics use:item amount:amountInt price:priceDouble];
}

- (void)bonus:(NSArray *)arguments {
    NSString *coin = [arguments objectAtIndex:0];
    if (coin == nil || [coin isKindOfClass:[NSNull class]]) {
        return;
    }
    NSString *source = [arguments objectAtIndex:1];
    if (source == nil && [source isKindOfClass:[NSNull class]]) {
        source = nil;
    }
    
    double coinDouble = [coin doubleValue];
    int sourceInt = [source doubleValue];
    [MobClickGameAnalytics bonus:coinDouble source:sourceInt];
}

- (void)bonusWithItem:(NSArray *)arguments {
    NSString *item = [arguments objectAtIndex:0];
    if (item == nil || [item isKindOfClass:[NSNull class]]) {
        return;
    }
    NSString *amount = [arguments objectAtIndex:1];
    if (amount == nil && [amount isKindOfClass:[NSNull class]]) {
        amount = nil;
    }
    NSString *price = [arguments objectAtIndex:2];
    if (price == nil && [price isKindOfClass:[NSNull class]]) {
        price = nil;
    }
    NSString *source = [arguments objectAtIndex:3];
    if (source == nil && [source isKindOfClass:[NSNull class]]) {
        source = nil;
    }
    
    int amountInt = [amount doubleValue];
    double priceDouble = [price doubleValue];
    int sourceInt = [source doubleValue];
    [MobClickGameAnalytics bonus:item amount:amountInt price:priceDouble source:sourceInt];
}

//Dplus
- (void)track:(NSArray *)arguments {
    NSString *eventName = [arguments objectAtIndex:0];
    if (eventName == nil || [eventName isKindOfClass:[NSNull class]]) {
        return;
    }
    [DplusMobClick track:eventName];
}

- (void)trackWithProperty:(NSArray *)arguments {
    NSString *eventName = [arguments objectAtIndex:0];
    if (eventName == nil || [eventName isKindOfClass:[NSNull class]]) {
        return;
    }
    NSDictionary *property = [arguments objectAtIndex:1];
    [DplusMobClick track:eventName property:property];
}

- (void)registerSuperProperty:(NSArray *)arguments {
    NSDictionary *property = [arguments objectAtIndex:0];
    [DplusMobClick registerSuperProperty:property];
}

- (void)unregisterSuperProperty:(NSArray *)arguments {
    NSString *propertyName = [arguments objectAtIndex:0];
    if (propertyName == nil || [propertyName isKindOfClass:[NSNull class]]) {
        return;
    }
    [DplusMobClick unregisterSuperProperty:propertyName];
}

- (void)getSuperProperty:(NSArray *)arguments webView:(UIWebView *)webView {
    NSString *propertyName = [arguments objectAtIndex:0];
    
    NSString *callBack = [NSString stringWithFormat:@"getSuperProperty('%@')",[DplusMobClick getSuperProperty:propertyName]];
    [webView stringByEvaluatingJavaScriptFromString:callBack];
    
}

- (void)getSuperProperties:(NSArray *)arguments  webView:(UIWebView *)webView {
    
    NSString *jsonString = nil;
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[DplusMobClick getSuperProperties]
                                                       options:kNilOptions //TODO: NSJSONWritingPrettyPrinted  // kNilOptions
                                                         error:&error];
    if ([jsonData length] && (error == nil))
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] ;
    }else{
        jsonString=@"";
    }
    
    NSString *callBack = [NSString stringWithFormat:@"getSuperProperties('%@')",jsonString];
    [webView stringByEvaluatingJavaScriptFromString:callBack];
}

- (void)clearSuperProperties:(NSArray *)arguments {
    [DplusMobClick clearSuperProperties];
}

- (void)setFirstLaunchEvent:(NSArray *)arguments {
    NSArray *eventList = [arguments objectAtIndex:0];
    [DplusMobClick setFirstLaunchEvent:eventList];
}

@end
