# 工程配置

* 注意：集成基础组件库 2.0.0以下及统计SDK 8.0.0以下版本的用户，请参考release1.0.0分支中样例代码集成。

首先需要说明，Hybrid下载的只是桥接文件，不含最新版本的jar，对应组件的jar请去[下载中心](https://developer.umeng.com/sdk)下载。

如果对于文档仍有疑问的，请参照我们在github上的[demo](https://github.com/umeng/Hybrid_Component)

## Android

### 初始化

将下载的jar放入app下的libs中：



![image.png](http://upload-images.jianshu.io/upload_images/1483670-9c93384e5a607551.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

首先需要拷贝common_android文件夹中的文件拷贝到你的工程中（路径为`com.umeng.hybrid`）：


![](http://upload-images.jianshu.io/upload_images/1483670-bee61cf3f7890608.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


然后再将对应平台的桥接文件根据需要拷入你的工程（跟需要使用组件的html文件在一起）：


![](http://upload-images.jianshu.io/upload_images/1483670-2867d41be28535af.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


打开Application文件，修改如下：

``` java
 @Override
	    public void onCreate() {
	        super.onCreate();

	        UMHBCommonSDK.setLogEnabled(true);
			UMHBCommonSDK.init(this, "59892f08310c9307b60023d0", "Umeng", UMConfigure.DEVICE_TYPE_PHONE,
	            "669c30a9584623e70e8cd01b0381dcb4");
	  
	    }
```

设置webview的WebChromeClient：

``` java

 class MyWebviewClient extends WebViewClient {

        @Override
        public void onPageFinished(WebView view, String url) {
            if (url != null && url.endsWith("/index.html")) {
                //MobclickAgent.onPageStart("index.html");
            }
        }

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            try {
                Log.d("UMHybrid", "shouldOverrideUrlLoading url:" + url);
                String decodedURL = java.net.URLDecoder.decode(url, "UTF-8");
                if (url.startsWith("umanalytics")) {
                    UMHBAnalyticsSDK.getInstance(MainActivity.this).execute(decodedURL, view);
                }else if (url.startsWith("umshare")){
                    UMHBSocialSDK.getInstance(MainActivity.this).execute(decodedURL, view);
                }else if (url.startsWith("umpush")){
                    UMHBPushSDK.getInstance(MainActivity.this).execute(decodedURL, view);
                }

            } catch (Exception e) {
                e.printStackTrace();
            }
            return false;
        }
    }
    
```
 
>`UMHBCommonSDK.init`接口一共五个参数，其中第一个参数为Context，第二个参数为友盟Appkey，第三个参数为channel，第四个参数为应用类型（手机或平板），第五个参数为push的secret（如果没有使用push，可以为空）。

至此，所有的工程配置已经完成，接下来请按照各个组件的文档进行初始化。

## iOS

### 初始化

+ 将已下载的友盟SDK添加到项目

![](http://upload-images.jianshu.io/upload_images/1483670-1dc704e7b7c5dd42.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


 
+ 添加友盟初始化配置文件

![](http://upload-images.jianshu.io/upload_images/1483670-647d9c2bb0df8aa4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

 
+ 在 Appdelegate.m 中设置初始化代码

```
#import "UMCommonModule.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [UMConfigure setLogEnabled:YES];
   [UMCommonModule initWithAppkey:@"571459ad67e58ea24c0016fd" channel:@"App Store"];
  ...
}
```

# 接口说明

# 统计

## Android

### 初始化

首先需要找到Activity的生命周期，添加如下代码：

```
  @Override
    public void onResume() {
        super.onResume();
        MobclickAgent.onResume(this);
    }
    @Override
    protected void onPause() {
        super.onPause();
        MobclickAgent.onPause(this);
    }
```


并在`onCreat`中设置统计的场景，以及发送间隔：

```
MobclickAgent.setSessionContinueMillis(1000*30);

```

## iOS
### 初始化
在工程的 AppDelegate.m 文件中引入相关组件头文件 ，且在 application:didFinishLaunchingWithOptions: 方法中添加如下代码：

```
[MobClick setScenarioType:E_UM_NORMAL];

```
如果需要引入多个场景：

```
[MobClick setScenarioType:E_UM_E_UM_GAME|E_UM_DPLUS];

```

js部分首先需要使用`UMAnalytics.js`文件：

设置webView

```
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString * url = [[request URL] absoluteString];
    NSString *parameters = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([UMAnalyticsModule execute:parameters webView:webView]) {
        return NO;
    } else if ([UMPushModule execute:parameters webView:webView]) {
        return NO;
    } else if ([UMShareModule execute:parameters webView:webView]) {
        return NO;
    }
    return YES;
}
```
设置WKWebView

```
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *url = [navigationAction.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *parameters = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
```

## 接口说明

### 自定义事件

```
UMAnalyticsAgent.onEvent(eventId);

UMAnalyticsAgent.onEventWithLable(eventId,eventLabel);

UMAnalyticsAgent.onEventWithParameters(eventId,eventData);

UMAnalyticsAgent.onEventWithCounter(eventId,eventData,eventNum);

UMAnalyticsAgent.onEventObject(eventId,eventData);

```
* eventId 为当前统计的事件ID
* eventLabel 为分类标签
* eventData 为当前事件的属性和取值（键值对），不能为空，如：{name:"umeng",sex:"man"}
* eventNum 用户每次触发的数值的分布情况，如事件持续时间、每次付款金额等

### 页面手动采集接口

```
UMAnalyticsAgent.onPageStart(pageName);

```

* pageName 页面名称

```
UMAnalyticsAgent.onPageEnd(pageName);

```

* pageName 页面名称


### 账号的统计

```
UMAnalyticsAgent.profileSignInWithPUID(puid);

```

* puid 用户账号ID.长度小于64字节

```
UMAnalyticsAgent.profileSignInWithPUIDWithProvider(provider, puid);

```

* provider 账号来源。 puid 用户账号ID.长度小于64字节


```
UMAnalyticsAgent.profileSignOff()；

```

* 账号登出时需调用此接口，调用之后不再发送账号相关内容



### 预置事件属性接口

```
UMAnalyticsAgent.registerPreProperties(property);
```

* 注册预置事件属性。property 事件的超级属性（可以包含多对“属性名-属性值”）,如：{name:"umeng",sex:"man"}

```
UMAnalyticsAgent.unregisterPreProperty(propertyName);
```

* 注销预置事件属性。propertyName，要注销的预置事件属性名。

```
UMAnalyticsAgent.getPreProperties(context);
```

* 获取预置事件属性, 返回包含所有预置事件属性的JSONObject。

``` 
UMAnalyticsAgent.clearPreProperties();
```

* 清空全部预置事件属性。


### 设置关注事件是否首次触发

```
UMAnalyticsAgent.setFirstLaunchEvent(eventList);
```

* eventList 只关注eventList前五个合法eventID.只要已经保存五个,此接口无效,如：["list1","list2","list3"]


# 推送

## Android

### 初始化

首先，Android push需要让Android app依赖我们提供的push module（请替换最新的umeng-push-3.3.1.jar），再根据文档进行相应的初始化。

Push SDK 的平台配置与单独 Native 项目集成相同，请参考 [接入Push SDK](http://dev.umeng.com/sdk_integate/android_sdk/android_push_doc#1) 以及 [初始化设置部分](http://dev.umeng.com/sdk_integate/android_sdk/android_push_doc#2_1)


## iOS

### 初始化

Push SDK 的平台配置与单独 Native 项目集成相同，请参考 [接入Push SDK](http://dev.umeng.com/sdk_integate/ios-integrate-guide/push#1) 以及 [初始化设置部分](http://dev.umeng.com/sdk_integate/ios-integrate-guide/push#1)

## 接口说明

首先需要使用`UMPush`文件：

### 添加tag

```
UMPushAgent.addTag('tag','remaincallback')
```

* tag 此参数为tag
* callback 第一个参数code为错误码，当为200时标记成功。第二个参数为remain值：

```
function remaincallback(stcode,remain) {
	alert('' +stcode+'   '+remain);
	}
```



### 删除tag

```
 UMPushAgent.delTag('tag','remaincallback')
```

* tag 此参数为tag
* callback 第一个参数code为错误码，当为200时标记成功。第二个参数为remain值：

```
function remaincallback(stcode,remain) {
	alert('' +stcode+'   '+remain);
	}
```



### 展示tag

```
UMPushAgent.listTag('listcallback')
```

* callback 为一个数组，标记为所有tag：

```
	function listcallback(taglist) {
	alert(taglist);
	}
```

### 添加Alias

```
UMPushAgent.addAlias('alias','type','aliascallback')
```

* alias 此参数为alias
* type  此参数为alias type
* aliascallback 为回调方法：


```
function aliascallback(stcode) {
	alert('' +stcode+'   ');
	}
```

### 添加额外Alias

```
UMPushAgent.setAlias('alias','type','aliascallback')
```

* alias 此参数为alias
* type  此参数为alias type
* aliascallback 为回调方法：

```
function aliascallback(stcode) {
	alert('' +stcode+'   ');
	}
```

### 删除Alias

```
UMPushAgent.delAlias('alias','type','aliascallback')
```

* alias 此参数为alias
* type  此参数为alias type
* aliascallback 为回调方法：

```
function aliascallback(stcode) {
	alert('' +stcode+'   ');
	}
```

# Share
## Android
### 初始化
在share_android文件夹下有一个social的module，开发者可以依赖这个module，并将下载所需的平台的jar放入这个module的lib中，也可以不依赖这个module，直接将使用平台的jar和res放入主module。
在Application中设置使用的三方平台的appkey：

```
 {

        PlatformConfig.setWeixin("wxdc1e388c3822c80b", "3baf1193c85774b3fd9d18447d76cab0");
        //豆瓣RENREN平台目前只能在服务器端配置
        PlatformConfig.setSinaWeibo("3921700954", "04b48b094faeb16683c32669824ebdad", "http://sns.whalecloud.com");
        PlatformConfig.setYixin("yxc0614e80c9304c11b0391514d09f13bf");
        PlatformConfig.setQQZone("100424468", "c7394704798a158208a74ab60104f0ba");

    }
```

找到使用的Activity，添加回调所需代码：

```
  @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        UMShareAPI.get(this).onActivityResult(requestCode, resultCode, data);
    }
```

分享其它工程配置请参照[分享工程配置](http://dev.umeng.com/sdk_integate/android_sdk/android_share_doc#1_3_2)

## iOS
### 初始化
UShare SDK 的平台配置与单独 Native 项目集成相同，请参考 [接入U-Share SDK](http://dev.umeng.com/social/ios/quick-integration#1_1) 以及 [初始化设置部分](http://dev.umeng.com/social/ios/quick-integration#2)

## 接口说明
首先需要使用`UMShare.js`文件：


### 授权

授权代码可以直接使用`UMShareAgent.doAuth( platform,'authcallback')`，其中platform为平台id，callback为回调内容。
平台与id的对应关系如下：


| id |平台 | 备注 |
| -------- | -------- | -------- |
| 0     | QQ     |     |
| 1     | SINA     |     |
| 2     | 微信     |     |
| 3     | 朋友圈     |     |
| 4     | QQ空间     |     |
| 5     | 电子邮件     |     |
| 6     | 短信     |     |
| 7     | facebook     |     |
| 8     | twitter     |     |
| 9     | 微信收藏     |     |
| 10     | google+     |     |
| 11     | 人人     |     |
| 12     | 腾讯微博     |     |
| 13     | 豆瓣     |     |
| 14     | facebook messager     |     |
| 15     | 易信     |     |
| 16     | 易信朋友圈     |     |
| 17     | INSTAGRAM     |     |
| 18     | PINTEREST     |     |
| 19     | 印象笔记     |     |
| 20     | POCKET     |     |
| 21     | LINKEDIN     |     |
| 22     | FOURSQUARE     |     |
| 23     | 有道云笔记     |     |
| 24     | WHATSAPP     |     |
| 25     | LINE     |     |
| 26     | FLICKR     |     |
| 27     | TUMBLR     |     |
| 28     | 支付宝     |     |
| 29     | KAKAO     |     |
| 30     | DROPBOX     |     |
| 31     | VKONTAKTE     |     |
| 32     | 钉钉     |     |
| 33     | 系统菜单     |     |

回调示例如下：

```
    function authcallback(stcode,result)
	{
        alert(result);
	}
```
其中stcode为错误码，当为200时标记为成功。
其中result为用户信息。
其中result属性如下：

| 属性 | 含义|
| -------- | -------- | 
| uid     | uid     | 
| screen_name     | 用户名     | 
| iconurl     | 头像     | 
| accessToken     | accessToken     | 
| refreshToken     | refreshToken| 
| gender     | gender     | 
| unionid     | unionid     | 
| openid     | openid     | 
| expires_in     | 过期时间     | 

### 分享
分享示例如下：

```
UMShareAgent.doShare( platform,text,img,url,title,callback)
```

* text 为分享内容
* img 为图片地址，可以为链接，本地地址以及res图片（如果使用res,请使用如下写法：`res/icon.png`）
* url 为分享链接，可以为空
* title 为分享链接的标题
* platform为平台id，id对照表与授权相同
* callback中code为错误码，当为200时，标记成功。
 
### 分享面板
分享面板示例如下：

```
UMShareAgent.openShare(platforms,text,img,url,title,callback)
```

* text 为分享内容
* img 为图片地址，可以为链接，本地地址以及res图片（如果使用res,请使用如下写法：`res/icon.png`）
* url 为分享链接，可以为空
* title 为分享链接的标题
* list 为分享平台数组，如：` var list = [0,1,2]`
* callback中code为错误码，当为200时，标记成功。

