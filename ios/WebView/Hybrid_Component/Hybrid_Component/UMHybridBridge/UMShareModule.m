//
//  ShareModule.h
//  UMComponent
//
//  Created by wyq.Cloudayc on 11/09/2017.
//  Copyright © 2017 Umeng. All rights reserved.
//

#import "UMShareModule.h"
#import <UMShare/UMShare.h>
#import <UShareUI/UShareUI.h>

@implementation UMShareModule

static UMShareModule *umengHyhrid = nil;

+ (BOOL)execute:(NSString *)parameters webView:(UIWebView *)webView {
    if ([parameters hasPrefix:@"umshare"]) {
        if (nil == umengHyhrid) {
            umengHyhrid = [[UMShareModule alloc] init];
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


- (UMSocialPlatformType)platformType:(NSInteger)platform
{
  switch (platform) {
    case 0: // QQ
      return UMSocialPlatformType_QQ;
    case 1: // Sina
      return UMSocialPlatformType_Sina;
    case 2: // wechat
      return UMSocialPlatformType_WechatSession;
    case 3:
      return UMSocialPlatformType_WechatTimeLine;
    case 4:
      return UMSocialPlatformType_Qzone;
    case 5:
      return UMSocialPlatformType_Email;
    case 6:
      return UMSocialPlatformType_Sms;
    case 7:
      return UMSocialPlatformType_Facebook;
    case 8:
      return UMSocialPlatformType_Twitter;
    case 9:
      return UMSocialPlatformType_WechatFavorite;
    default:
      return UMSocialPlatformType_QQ;
  }
}

- (void)shareWithText:(NSString *)text icon:(NSString *)icon link:(NSString *)link title:(NSString *)title platform:(NSInteger)platform completion:(UMSocialRequestCompletionHandler)completion
{
  UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
  
  if (link.length > 0) {
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:text thumImage:icon];
    shareObject.webpageUrl = link;
    
    messageObject.shareObject = shareObject;
  } else if (icon.length > 0) {
    id img = nil;
    if ([icon hasPrefix:@"http"]) {
      img = icon;
    } else {
      if ([icon hasPrefix:@"/"]) {
        img = [UIImage imageWithContentsOfFile:icon];
      } else {
        img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:icon ofType:nil]];
      }
    }
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    shareObject.thumbImage = img;
    shareObject.shareImage = img;
    messageObject.shareObject = shareObject;
    
    messageObject.text = text;
  } else if (text.length > 0) {
    messageObject.text = text;
  } else {
    if (completion) {
      completion(nil, [NSError errorWithDomain:@"UShare" code:-3 userInfo:@{@"message": @"invalid parameter"}]);
      return;
    }
  }
  
  [[UMSocialManager defaultManager] shareToPlatform:platform messageObject:messageObject currentViewController:nil completion:completion];
  
}

- (void)shareWithPlatform:(UMSocialPlatformType)platform text:(NSString *)text icon:(NSString *)icon link:(NSString *)link title:(NSString *)title platform:(NSInteger)platform completion:(id)completion
{
  UMSocialPlatformType plf = [self platformType:platform];
  if (plf == UMSocialPlatformType_UnKnown) {
    if (completion) {
//      completion(@[@(UMSocialPlatformType_UnKnown), @"invalid platform"]);
      return;
    }
  }
  
  [self shareWithText:text icon:icon link:link title:title platform:plf completion:^(id result, NSError *error) {
    if (completion) {
      if (error) {
        NSString *msg = error.userInfo[@"NSLocalizedFailureReason"];
        if (!msg) {
          msg = error.userInfo[@"message"];
        }if (!msg) {
          msg = @"share failed";
        }
        
//        completion(@[@(error.code), msg]);
      } else {
//        completion(@[@0, @"share success"]);
      }
    }
  }];
  
}

- (void)shareBoard:(UMSocialPlatformType)platform text:(NSString *)text icon:(NSString *)icon link:(NSString *)link title:(NSString *)title platform:(NSInteger)platform completion:(id)completion
{
  NSMutableArray *plfs = [NSMutableArray array];
//  for (NSNumber *plf in platforms) {
//    [plfs addObject:@([self platformType:plf.integerValue])];
//  }
  if (plfs.count > 0) {
    [UMSocialUIManager setPreDefinePlatforms:plfs];
  }
  [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
    [self shareWithText:text icon:icon link:link title:title platform:platformType completion:^(id result, NSError *error) {
      if (completion) {
        if (error) {
          NSString *msg = error.userInfo[@"NSLocalizedFailureReason"];
          if (!msg) {
            msg = error.userInfo[@"message"];
          }if (!msg) {
            msg = @"share failed";
          }
          
//          completion(@[@(error.code), msg]);
        } else {
//          completion(@[@0, @"share success"]);
        }
      }
    }];
  }];
}


- (void)getUserInfoWithPlatform:(UMSocialPlatformType)platform withCompletion:(UMSocialGetUserInfoCompletionHandler)completion
{
  UMSocialPlatformType plf = [self platformType:platform];
  if (plf == UMSocialPlatformType_UnKnown) {
    if (completion) {
//      completion(@[@(UMSocialPlatformType_UnKnown), @"invalid platform"]);
      return;
    }
  }
  
  [[UMSocialManager defaultManager] getUserInfoWithPlatform:plf currentViewController:nil completion:^(id result, NSError *error) {
    if (completion) {
      if (error) {
        NSString *msg = error.userInfo[@"NSLocalizedFailureReason"];
        if (!msg) {
          msg = error.userInfo[@"message"];
        }if (!msg) {
          msg = @"share failed";
        }
        
//        completion(@[@(error.code), @{}, msg]);
      } else {
        UMSocialUserInfoResponse *authInfo = result;
        
        NSMutableDictionary *retDict = [NSMutableDictionary dictionaryWithCapacity:8];
        retDict[@"uid"] = authInfo.uid;
        retDict[@"openid"] = authInfo.openid;
        retDict[@"unionid"] = authInfo.unionId;
        retDict[@"accessToken"] = authInfo.accessToken;
        retDict[@"refreshToken"] = authInfo.refreshToken;
        retDict[@"expiration"] = authInfo.expiration;
        
        retDict[@"name"] = authInfo.name;
        retDict[@"iconurl"] = authInfo.iconurl;
        retDict[@"gender"] = authInfo.unionGender;
        
        NSDictionary *originInfo = authInfo.originalResponse;
        retDict[@"city"] = originInfo[@"city"];
        retDict[@"province"] = originInfo[@"province"];
        retDict[@"country"] = originInfo[@"country"];
        
//        completion(@[@0, retDict, @""]);
      }
    }
  }];
  
}
@end
