//
//  ViewController.m
//  Hybrid_Component
//
//  Created by wangkai on 2017/9/25.
//  Copyright © 2017年 wangkai. All rights reserved.
//

#import "ViewController.h"
#import <UMAnalytics/MobClick.h>
#import "UMAnalyticsModule.h"
#import "UMShareModule.h"
#import "UMPushModule.h"
@interface ViewController () <WKNavigationDelegate>

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - UIWebViewDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *url = [navigationAction.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *parameters = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([UMAnalyticsModule execute:parameters webView:webView]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else if ([UMPushModule execute:parameters webView:webView]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else if ([UMShareModule execute:parameters webView:webView]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}


@end
