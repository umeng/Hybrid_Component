package com.umeng.soexample;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.webkit.JsResult;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import com.umeng.analytics.MobclickAgent;
import com.umeng.hybrid.UMHBAnalyticsSDK;
import com.umeng.hybrid.UMHBPushSDK;
import com.umeng.hybrid.UMHBSocialSDK;
import com.umeng.socialize.UMShareAPI;

public class MainActivity extends Activity {
    WebView webView ;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        webView = findViewById(R.id.webview);
        webView.getSettings().setJavaScriptEnabled(true);
        webView.loadUrl("file:///android_asset/index.html");
        webView.setWebViewClient(new MyWebviewClient());
        webView.setWebChromeClient(new MyChromeClient());


        MobclickAgent.setSessionContinueMillis(1000);

    }
    @Override
    public void onResume() {
        super.onResume();
        MobclickAgent.onResume(this);
    }

    @Override
    public void onPause() {
        super.onPause();
        MobclickAgent.onPause(this);
    }
    class MyChromeClient extends WebChromeClient {
        @Override
        public boolean onJsAlert(WebView view, String url, String message, final JsResult result) {

            return false;
        }
    }
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

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        UMShareAPI.get(this).onActivityResult(requestCode,resultCode,data);
    }
}
