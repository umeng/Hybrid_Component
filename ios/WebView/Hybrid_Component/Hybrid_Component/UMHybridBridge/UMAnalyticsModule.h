//
//  analytics.h
//  analytics
//
//
//  Copyright (c) 2016年 tendcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UMAnalyticsModule : NSObject

+ (BOOL)execute:(NSString *)parameters webView:(UIWebView *)webView;


@end
