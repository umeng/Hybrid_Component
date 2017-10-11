package com.umeng.hybrid;

import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.webkit.WebView;
import com.umeng.message.PushAgent;
import com.umeng.message.UTrack;
import com.umeng.message.common.inter.ITagManager;
import com.umeng.message.tag.TagManager;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by wangfei on 17/9/28.
 */

public class UMHBPushSDK {
    private static Activity mactivity = null;
    private final int SUCCESS = 200;
    private final int ERROR = 0;
    private static Handler mSDKHandler = new Handler(Looper.getMainLooper());
    private final int CANCEL = -1;
    private PushAgent mPushAgent;
    private static class Holder {
        private static final UMHBPushSDK INSTANCE = new UMHBPushSDK();
    }

    private UMHBPushSDK() {
        mPushAgent = PushAgent.getInstance(mactivity);
    }
    private static void runOnMainThread(Runnable runnable) {
        mSDKHandler.postDelayed(runnable, 0);
    }


    public static UMHBPushSDK getInstance(Context context) {
        if (context != null) {

            mactivity = (Activity)context;
        }

        return Holder.INSTANCE;
    }

    public void execute(final String url, final WebView webView) throws Exception {

        if (url.startsWith("umpush")) {
            String str = url.substring(7);

            JSONObject jsonObj = new JSONObject(str);
            String functionName = jsonObj.getString("functionName");
            JSONArray args = jsonObj.getJSONArray("arguments");
            Log.d("UMHybrid", "functionName:" + functionName + "|||args:" + args.toString());
            if (functionName.equals("addTag")) {
                String tag = args.getString(0);
                final String callback = args.getString(1);
                mPushAgent.getTagManager().addTags(new TagManager.TCallBack() {
                    @Override
                    public void onMessage(final boolean isSuccess, final ITagManager.Result result) {
                        if (isSuccess) {
                           remaincallbackJS(webView,callback,SUCCESS,result.remain);

                        } else {
                            remaincallbackJS(webView,callback,ERROR,0);
                        }
                    }
                }, tag);
            }else if (functionName.equals("delTag")){
                String tag = args.getString(0);
                final String callback = args.getString(1);
                mPushAgent.getTagManager().deleteTags(new TagManager.TCallBack() {
                    @Override
                    public void onMessage(final boolean isSuccess, final ITagManager.Result result) {
                        if (isSuccess) {
                            remaincallbackJS(webView,callback,SUCCESS,result.remain);

                        } else {
                            remaincallbackJS(webView,callback,ERROR,0);
                        }
                    }
                }, tag);
            }else if (functionName.equals("listTag")){
                final String callback = args.getString(0);
                mPushAgent.getTagManager().getTags(new TagManager.TagListCallBack() {
                    @Override
                    public void onMessage(final boolean isSuccess, final List<String> result) {

                        if (isSuccess) {
                            if (result != null) {
                                String r = "";
                                for (int i = 0; i < result.size(); i++) {
                                    r = r + result.get(i) + ",";
                                }
                                r.substring(0, r.length() - 1);
                                tagscallbackJS(webView,callback,getJsonArry(result));
                            } else {
                                tagscallbackJS(webView,callback,new JSONArray());
                            }
                        } else {
                            tagscallbackJS(webView,callback,new JSONArray());
                        }

                    }
                });
            }else if (functionName.equals("addAlias")){
                String alias = args.getString(0);
                String aliasType = args.getString(1);
                final String callback = args.getString(2);
                mPushAgent.addAlias(alias, aliasType, new UTrack.ICallBack() {
                    @Override
                    public void onMessage(final boolean isSuccess, final String message) {

                        Log.e("xxxxxx", "isuccess" + isSuccess);
                        if (isSuccess) {
                         aliascallbackJS(webView,callback,SUCCESS);
                        } else {
                            aliascallbackJS(webView,callback,ERROR);
                        }

                    }
                });
            }else if (functionName.equals("setAlias")){
                String alias = args.getString(0);
                String aliasType = args.getString(1);
                final String callback = args.getString(2);
                mPushAgent.setAlias(alias, aliasType, new UTrack.ICallBack() {
                    @Override
                    public void onMessage(final boolean isSuccess, final String message) {


                        if (isSuccess) {
                            aliascallbackJS(webView,callback,SUCCESS);
                        } else {
                            aliascallbackJS(webView,callback,ERROR);
                        }

                    }
                });
            }else if (functionName.equals("delAlias")){
                String alias = args.getString(0);
                String aliasType = args.getString(1);
                final String callback = args.getString(2);
                mPushAgent.deleteAlias(alias, aliasType, new UTrack.ICallBack() {
                    @Override
                    public void onMessage(final boolean isSuccess, final String message) {


                        if (isSuccess) {
                            aliascallbackJS(webView,callback,SUCCESS);
                        } else {
                            aliascallbackJS(webView,callback,ERROR);
                        }

                    }
                });
            }
        }
    }
    private void remaincallbackJS(final WebView webView, final String cb, final int code , final int remain){
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                webView.loadUrl("javascript:" + cb + "(" + "'"+code+"'"+","+"'"+remain+"'"+")");
            }
        });

    }
    private void tagscallbackJS(final WebView webView, final String cb, final JSONArray list ){

        runOnMainThread(new Runnable() {
            @Override
            public void run() {

                webView.loadUrl("javascript:" + cb + "(" + "'"+list+"'"+")");
            }
        });

    }
    private void aliascallbackJS(final WebView webView, final String cb, final int stcode ){
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                Log.d("UMHybrid","javascript:" + cb + "(" + "'"+stcode+"'"+")");
                webView.loadUrl("javascript:" + cb + "(" + "'"+stcode+"'"+")");
            }
        });

    }
    private JSONArray getJsonArry(List<String> list) {
        JSONArray jsonArray = new JSONArray();
        for (String t : list) {
            jsonArray.put(t);
        }
        return jsonArray;
    }

    private JSONObject getTagJson(int stCode, int remain) {
        try {
            JSONObject object = new JSONObject();
            object.put("stcode", stCode);
            object.put("remain", remain);
            return object;
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null;
    }
}
