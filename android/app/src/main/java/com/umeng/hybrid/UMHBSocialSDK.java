package com.umeng.hybrid;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

import android.app.Activity;
import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.BitmapFactory;
import android.text.TextUtils;
import android.util.Log;
import android.webkit.WebView;
import com.umeng.socialize.ShareAction;
import com.umeng.socialize.UMAuthListener;
import com.umeng.socialize.UMShareAPI;
import com.umeng.socialize.UMShareListener;
import com.umeng.socialize.bean.SHARE_MEDIA;
import com.umeng.socialize.common.ResContainer;
import com.umeng.socialize.media.UMImage;
import com.umeng.socialize.media.UMWeb;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by wangfei on 17/9/28.
 */

public class UMHBSocialSDK {

    private static Activity mactivity = null;
    private final int SUCCESS = 200;
    private final int ERROR = 0;
    private final int CANCEL = -1;
    private static class Holder {
        private static final UMHBSocialSDK INSTANCE = new UMHBSocialSDK();
    }

    private UMHBSocialSDK() {
    }



    public static UMHBSocialSDK getInstance(Context context) {
        if (context != null) {

            mactivity = (Activity)context;
        }
        return Holder.INSTANCE;
    }

    public void execute(final String url, final WebView webView) throws Exception {

        if (url.startsWith("umshare")) {
            String str = url.substring(8);

            JSONObject jsonObj = new JSONObject(str);
            String functionName = jsonObj.getString("functionName");
            JSONArray args = jsonObj.getJSONArray("arguments");
            Log.d("UMHybrid", "functionName:" + functionName + "|||args:" + args.toString());
            if (functionName.equals("share")) {
                String text = args.getString(1);
                String img = args.getString(2);
                String targeturl = args.getString(3);
                String title = args.getString(4);
                int platform = args.getInt(0);
                final String callBack = args.getString(5);
                ShareAction shareAction = getShareAction(text,img,targeturl,title);
                shareAction.setPlatform(getPlatform(platform));
                shareAction.setCallback(new UMShareListener() {
                    @Override
                    public void onStart(SHARE_MEDIA share_media) {

                    }

                    @Override
                    public void onResult(SHARE_MEDIA share_media) {
                        sharecallbackJS(webView,callBack,SUCCESS);
                    }

                    @Override
                    public void onError(SHARE_MEDIA share_media, Throwable throwable) {
                        sharecallbackJS(webView,callBack,ERROR);
                    }

                    @Override
                    public void onCancel(SHARE_MEDIA share_media) {
                        sharecallbackJS(webView,callBack,CANCEL);
                    }
                }).share();
            }else if (functionName.equals("shareBoard")){
                String text = args.getString(1);
                String img = args.getString(2);
                String targeturl = args.getString(3);
                String title = args.getString(4);
                JSONArray platforms = args.getJSONArray(0);
                final String callBack = args.getString(5);
                ShareAction shareAction = getShareAction(text,img,targeturl,title);
                shareAction.setDisplayList(getPlatforms(platforms));
                shareAction.setCallback(new UMShareListener() {
                    @Override
                    public void onStart(SHARE_MEDIA share_media) {

                    }

                    @Override
                    public void onResult(SHARE_MEDIA share_media) {
                        sharecallbackJS(webView,callBack,SUCCESS);
                    }

                    @Override
                    public void onError(SHARE_MEDIA share_media, Throwable throwable) {
                        sharecallbackJS(webView,callBack,ERROR);
                    }

                    @Override
                    public void onCancel(SHARE_MEDIA share_media) {
                        sharecallbackJS(webView,callBack,CANCEL);
                    }
                }).open();
            }else if (functionName.equals("doAuth")){
                int platform = args.getInt(0);
                final String callBack = args.getString(1);
                UMShareAPI.get(mactivity).getPlatformInfo(mactivity, getPlatform(platform), new UMAuthListener() {
                    @Override
                    public void onStart(SHARE_MEDIA share_media) {

                    }

                    @Override
                    public void onComplete(SHARE_MEDIA share_media, int i, Map<String, String> map) {
                        try {
                            authcallbackJS(webView,callBack,SUCCESS,map2Json(map));
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }

                    @Override
                    public void onError(SHARE_MEDIA share_media, int i, Throwable throwable) {
                        try {
                            JSONObject object = new JSONObject();
                            object.put("error",throwable.getMessage());
                            authcallbackJS(webView,callBack,ERROR,object);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }

                    @Override
                    public void onCancel(SHARE_MEDIA share_media, int i) {
                        try {
                            JSONObject object = new JSONObject();
                            object.put("error","cancel");
                            authcallbackJS(webView,callBack,CANCEL,object);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                });
            }
        }
    }
    private JSONObject map2Json(Map<String,String> map) throws JSONException {
        JSONObject object = new JSONObject();
        for (String key:map.keySet()){
            object.put(key,map.get(key));
        }
        return object;
    }
    private void sharecallbackJS(WebView webView,String cb, int code ){
        Log.d("UMHybrid", "javascript:" + cb + "(" + "'"+code+"'"+")");
        webView.loadUrl("javascript:" + cb + "(" + "'"+code+"'"+")");
    }

    private void authcallbackJS(WebView webView,String cb, int code ,JSONObject map){
        Log.d("UMHybrid", "javascript:" + cb + "(" + "'"+code+"'"+","+map+")");
        webView.loadUrl("javascript:" + cb + "(" + "'"+code+"'"+","+map+")");
    }
    private ShareAction getShareAction(String text, String img , String url, String title){
        ShareAction shareAction = new ShareAction(mactivity);
        if (!TextUtils.isEmpty(url)){
            UMWeb umWeb = new UMWeb(url);
            umWeb.setThumb(parseShareImage(img));
            umWeb.setTitle(title);
            umWeb.setDescription(text);
            shareAction.withMedia(umWeb);
        }else if (!TextUtils.isEmpty(img)){
            UMImage image = parseShareImage(img);
            image.setThumb(parseShareImage(img));
            shareAction.withMedia(image);
        }
        if (!TextUtils.isEmpty(text)){
            shareAction.withText(text);
        }
        return shareAction;
    }
    private UMImage parseShareImage(String imgName) {
        if(TextUtils.isEmpty(imgName)) {

            return null;
        } else {
            UMImage shareImage = null;
            if(imgName.startsWith("http")) {
                shareImage = new UMImage(mactivity, imgName);
            } else if(imgName.startsWith("assets/")) {
                AssetManager imgFile = mactivity.getResources().getAssets();
                String index = getFileName(imgName);
                InputStream imgNameString = null;
                if(!TextUtils.isEmpty(index)) {
                    try {
                        imgNameString = imgFile.open(index);
                        shareImage = new UMImage(mactivity, BitmapFactory.decodeStream(imgNameString));
                        imgNameString.close();
                    } catch (IOException var14) {
                        var14.printStackTrace();
                    } finally {
                        if(imgNameString != null) {
                            try {
                                imgNameString.close();
                            } catch (IOException var13) {
                                var13.printStackTrace();
                            }
                        }

                    }
                }
            } else if(imgName.startsWith("res/")) {
                String imgFile1 = getFileName(imgName);
                if(!TextUtils.isEmpty(imgFile1)) {
                    int index1 = imgFile1.indexOf(".");
                    if(index1 > 0) {
                        String imgNameString1 = imgFile1.substring(0, index1);
                        int imgId = ResContainer.getResourceId(mactivity, "drawable", imgNameString1);
                        shareImage = new UMImage(mactivity, imgId);
                    } else {

                    }
                }
            } else {
                File imgFile2 = new File(imgName);
                if(!imgFile2.exists()) {

                } else {
                    shareImage = new UMImage(mactivity, imgFile2);
                }
            }

            return shareImage;
        }
    }
    private static String getFileName(String fullname) {
        return !fullname.startsWith("assets/") && !fullname.startsWith("res/")?"":fullname.split("/")[1];
    }
    private SHARE_MEDIA[] getPlatforms(JSONArray platforms){
        SHARE_MEDIA[] ss = new SHARE_MEDIA[platforms.length()];
        for (int i = 0;i<platforms.length();i++){
            try {
                ss[i] = getPlatform(platforms.getInt(i));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return ss;
    }
    private SHARE_MEDIA getPlatform(int platform){
        switch (platform){
            case 0:
                return SHARE_MEDIA.QQ;

            case 1:
                return SHARE_MEDIA.SINA;

            case 2:
                return SHARE_MEDIA.WEIXIN;

            case 3:
                return SHARE_MEDIA.WEIXIN_CIRCLE;
            case 4:
                return SHARE_MEDIA.QZONE;
            case 5:
                return SHARE_MEDIA.EMAIL;
            case 6:
                return SHARE_MEDIA.SMS;
            case 7:
                return SHARE_MEDIA.FACEBOOK;
            case 8:
                return SHARE_MEDIA.TWITTER;
            case 9:
                return SHARE_MEDIA.WEIXIN_FAVORITE;
            case 10:
                return SHARE_MEDIA.GOOGLEPLUS;
            case 11:
                return SHARE_MEDIA.RENREN;
            case 12:
                return SHARE_MEDIA.TENCENT;
            case 13:
                return SHARE_MEDIA.DOUBAN;
            case 14:
                return SHARE_MEDIA.FACEBOOK_MESSAGER;
            case 15:
                return SHARE_MEDIA.YIXIN;
            case 16:
                return SHARE_MEDIA.YIXIN_CIRCLE;
            case 17:
                return SHARE_MEDIA.INSTAGRAM;
            case 18:
                return SHARE_MEDIA.PINTEREST;
            case 19:
                return SHARE_MEDIA.EVERNOTE;
            case 20:
                return SHARE_MEDIA.POCKET;
            case 21:
                return SHARE_MEDIA.LINKEDIN;
            case 22:
                return SHARE_MEDIA.FOURSQUARE;
            case 23:
                return SHARE_MEDIA.YNOTE;
            case 24:
                return SHARE_MEDIA.WHATSAPP;
            case 25:
                return SHARE_MEDIA.LINE;
            case 26:
                return SHARE_MEDIA.FLICKR;
            case 27:
                return SHARE_MEDIA.TUMBLR;
            case 28:
                return SHARE_MEDIA.ALIPAY;
            case 29:
                return SHARE_MEDIA.KAKAO;
            case 30:
                return SHARE_MEDIA.DROPBOX;
            case 31:
                return SHARE_MEDIA.VKONTAKTE;
            case 32:
                return SHARE_MEDIA.DINGTALK;
            case 33:
                return SHARE_MEDIA.MORE;
            default:
                return SHARE_MEDIA.QQ;
        }
    }

}
