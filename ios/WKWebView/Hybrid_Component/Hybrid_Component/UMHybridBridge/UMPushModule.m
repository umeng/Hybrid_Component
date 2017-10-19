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

+ (BOOL)execute:(NSString *)parameters webView:(WKWebView *)webView {
    NSString *prefix = @"umpush";
     NSLog(@"11111");
    if ([parameters hasPrefix:prefix]) {
        NSLog(@"22222");
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
              SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:webView:", functionName]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([umengHyhrid respondsToSelector:selector]) {
                [umengHyhrid performSelector:selector withObject:args withObject:webView];
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

- (void)getDeviceId:(NSArray *)arguments webView:(WKWebView *)webView {
    NSString *arg0 = [arguments objectAtIndex:0];
    if (arg0 == nil || [arg0 isKindOfClass:[NSNull class]] || arg0.length == 0) {
        return;
    }
    
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *callBack = [NSString stringWithFormat:@"%@('%@')", arg0, deviceId];
    [webView evaluateJavaScript:callBack completionHandler:nil];
    
}
- (void)addTag:(NSArray *)arguments webView:(WKWebView *)webView{
      NSLog(@"333");
     NSString *arg0 = [arguments objectAtIndex:0];
     NSString *cb = [arguments objectAtIndex:1];
    [UMessage addTags:arg0 response:^(id  _Nonnull responseObject, NSInteger remain, NSError * _Nonnull error) {
        int code = -1;
        int remainnum = 0;
        if (error) {
            code = error.code;
        }else{
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *respobj = responseObject;
                // 授权信息
                if ([[respobj allKeys] containsObject:@"success"]) {
                    if ([[respobj objectForKey:@"success"] isEqualToString:@"ok"]) {
                        code = 200 ;
                    }
                }
                if ([[respobj allKeys] containsObject:@"remain"]) {
                    remainnum = [[respobj objectForKey:@"remain"] intValue];
                }
            }
        }
        [self handleRemainResult:code remain:remainnum callbackFunction:cb webView:webView];
//        callback(code, remainnum);
        
    }];
}
- (void)delTag:(NSArray *)arguments webView:(WKWebView *)webView{
   
    NSString *arg0 = [arguments objectAtIndex:0];
    NSString *cb = [arguments objectAtIndex:1];
    [UMessage deleteTags:arg0 response:^(id  _Nonnull responseObject, NSInteger remain, NSError * _Nonnull error) {
        int code = -1;
        int remainnum = 0;
        if (error) {
            code = error.code;
        }else{
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *respobj = responseObject;
                // 授权信息
                if ([[respobj allKeys] containsObject:@"success"]) {
                    if ([[respobj objectForKey:@"success"] isEqualToString:@"ok"]) {
                        code = 200 ;
                    }
                }
                if ([[respobj allKeys] containsObject:@"remain"]) {
                    remainnum = [[respobj objectForKey:@"remain"] intValue];
                }
            }
        }
        [self handleRemainResult:code remain:remainnum callbackFunction:cb webView:webView];
        //        callback(code, remainnum);
        
    }];
}
- (void)listTag:(NSArray *)arguments webView:(WKWebView *)webView{
     NSString *cb = [arguments objectAtIndex:0];
    [UMessage getTags:^(NSSet * _Nonnull responseTags, NSInteger remain, NSError * _Nonnull error) {
        int code = -1;
        NSString *tags = @"[";
       
        int remainnum = 0;
        if (error) {
            code = error.code;
        }else{
            if ([responseTags isKindOfClass:[NSSet class]]) {
                NSArray * tagsarray = [responseTags allObjects];
//                for (int i = 0; i < tagsarray.count; i++) {
//                    NSString *str = tagsarray[i];
                 tags = [tagsarray componentsJoinedByString:@","];
//                }
                tags = [tags stringByAppendingString:@"]"];
            }
        }
       
        NSLog(@"%@",tags);
        [self handleTagsResult:tags callbackFunction:cb webView:webView];
//        callback(code,tags);
    }];
}
- (void)addAlias:(NSArray *)arguments webView:(WKWebView *)webView{
    NSString *arg0 = [arguments objectAtIndex:0];
     NSString *arg1 = [arguments objectAtIndex:1];
    NSString *cb = [arguments objectAtIndex:2];
    [UMessage addAlias:arg0 type:arg1 response:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
        int code = -1;
        int remainnum = 0;
        if (error) {
            code = error.code;
        }else{
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *respobj = responseObject;
                // 授权信息
                if ([[respobj allKeys] containsObject:@"success"]) {
                    if ([[respobj objectForKey:@"success"] isEqualToString:@"ok"]) {
                        code = 200 ;
                    }
                }
            }
        }
        [self handleAliasResult:code callbackFunction:cb webView:webView];
      
    }];
}
- (void)delAlias:(NSArray *)arguments webView:(WKWebView *)webView{
    NSString *arg0 = [arguments objectAtIndex:0];
    NSString *arg1 = [arguments objectAtIndex:1];
    NSString *cb = [arguments objectAtIndex:2];
    [UMessage removeAlias:arg0 type:arg1 response:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
        int code = -1;
        int remainnum = 0;
        if (error) {
            code = error.code;
        }else{
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *respobj = responseObject;
                // 授权信息
                if ([[respobj allKeys] containsObject:@"success"]) {
                    if ([[respobj objectForKey:@"success"] isEqualToString:@"ok"]) {
                        code = 200 ;
                    }
                }
            }
        }
        [self handleAliasResult:code callbackFunction:cb webView:webView];
        
    }];
}
- (void)setAlias:(NSArray *)arguments webView:(WKWebView *)webView{
    NSString *arg0 = [arguments objectAtIndex:0];
    NSString *arg1 = [arguments objectAtIndex:1];
    NSString *cb = [arguments objectAtIndex:2];
    [UMessage setAlias:arg0 type:arg1 response:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
        int code = -1;
        int remainnum = 0;
        if (error) {
            code = error.code;
        }else{
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *respobj = responseObject;
                // 授权信息
                if ([[respobj allKeys] containsObject:@"success"]) {
                    if ([[respobj objectForKey:@"success"] isEqualToString:@"ok"]) {
                        code = 200 ;
                    }
                }
            }
        }
        [self handleAliasResult:code callbackFunction:cb webView:webView];
        
    }];
}
- (void)handleAliasResult:(NSInteger)retCode  callbackFunction:(NSString *)function webView:(WKWebView *)webView
{
    if (function.length == 0) {
        return;
    }
  
    
    
    NSString *callBack = [NSString stringWithFormat:@"%@(%ld)", function, retCode];
    NSString *callBackAlert =[NSString stringWithFormat:@"setTimeout(function(){%@;},1)",callBack];
    [webView evaluateJavaScript:callBackAlert completionHandler:nil];

}
- (void)handleTagsResult:(NSString *)tags callbackFunction:(NSString *)function webView:(WKWebView *)webView
{
    if (function.length == 0) {
        return;
    }
    
    NSString *callBack = [NSString stringWithFormat:@"%@('%@\')", function, tags];
    NSString *callBackAlert =[NSString stringWithFormat:@"setTimeout(function(){%@;},1)",callBack];
    [webView evaluateJavaScript:callBackAlert completionHandler:nil];

}
- (void)handleRemainResult:(NSInteger)retCode remain:(NSInteger)remain callbackFunction:(NSString *)function webView:(WKWebView *)webView
{
    if (function.length == 0) {
        return;
    }
    NSString *callBack = [NSString stringWithFormat:@"%@(%ld,%ld)", function, retCode, remain];
    NSString *callBackAlert =[NSString stringWithFormat:@"setTimeout(function(){%@;},1)",callBack];
    [webView evaluateJavaScript:callBackAlert completionHandler:nil];

}
@end
