package com.umeng.hybrid;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import android.content.Context;
import android.util.Log;
import android.webkit.WebView;
import com.umeng.analytics.MobclickAgent;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * 示例： SDK 接口桥接封装类，并未封装SDK所有API(仅封装常用API接口)，设置配置参数类API应在Android原生代码中
 * 调用，例如：SDK初始化函数，Log开关函数，子进程自定义事件埋点使能函数，异常捕获功能使能/关闭函数等等。
 * 如果还需要封装其它SDK API，请参考本例自行封装。
 * Created by wangfei on 17/9/28.
 * -- 适配(common 2.0.0 + analytics 8.0.0) modify by yujie on 18/12/28
 */

public class UMHBAnalyticsSDK {
    private static Context mContext = null;

    private static class Holder {
        private static final UMHBAnalyticsSDK INSTANCE = new UMHBAnalyticsSDK();
    }

    private UMHBAnalyticsSDK() {
    }

    public static UMHBAnalyticsSDK getInstance(Context context) {
        if (context != null) {
            mContext = context.getApplicationContext();
        }
        return Holder.INSTANCE;
    }

    public void execute(final String url, final WebView webView) throws Exception {

        if (url.startsWith("umanalytics")) {
            String str = url.substring(12);

            JSONObject jsonObj = new JSONObject(str);
            String functionName = jsonObj.getString("functionName");
            // 参数列统一用JSONArray传入，参数解析在具体封装函数中进行。
            JSONArray args = jsonObj.getJSONArray("arguments");
            Log.d("UMHybrid", "functionName:" + functionName + "|||args:" + args.toString());
            if (functionName.equals("getDeviceId")) {
                getDeviceId(args, webView);
            } else if (functionName.equals("getPreProperties")) {
                getPreProperties(args, webView); // 需要通过js callback返回结果
            } else {
                Class<UMHBAnalyticsSDK> classType = UMHBAnalyticsSDK.class;
                Method method = classType.getDeclaredMethod(functionName, JSONArray.class);
                method.invoke(getInstance(mContext), args);
            }
        }
    }

    private void getDeviceId(JSONArray args, WebView webView) {
        Log.d("UMHybrid", "getDeviceId  args:" + args.toString());
        try {
            android.telephony.TelephonyManager tm = (android.telephony.TelephonyManager) mContext
                .getSystemService(Context.TELEPHONY_SERVICE);
            String deviceId = tm.getDeviceId();
            String callBack = args.getString(0);
            webView.loadUrl("javascript:" + callBack + "('" + deviceId + "')");
        } catch (Exception e) {
            e.toString();
        }
    }

    /**
     *
     * @param args
     * @param webView
     */
    private void getPreProperties(JSONArray args, WebView webView) {
        Log.d("UMHybrid", "getPreProperties args:" + args.toString());
        try {
            String properties = MobclickAgent.getPreProperties(mContext).toString();
            String callBack = args.getString(0);
            webView.loadUrl("javascript:" + callBack + "('" + properties + "')");

        } catch (Exception e) {
            e.toString();
        }
    }

    @SuppressWarnings("unused")
    private void onEvent(final JSONArray args) throws JSONException {
        Log.d("UMHybrid", "onEvent  args:" + args.toString());
        String eventId = args.getString(0);
        MobclickAgent.onEvent(mContext, eventId);
    }

    @SuppressWarnings("unused")
    private void onEventWithLabel(final JSONArray args) throws JSONException {
        Log.d("UMHybrid", "onEventWithLabel  args:" + args.toString());
        String eventId = args.getString(0);
        String label = args.getString(1);
        MobclickAgent.onEvent(mContext, eventId, label);
    }

    @SuppressWarnings({ "unused" })
    private void onEventWithParameters(final JSONArray args) throws JSONException {
        Log.d("UMHybrid", "onEventWithParameters  args:" + args.toString());
        String eventId = args.getString(0);
        JSONObject obj = args.getJSONObject(1);
        Map<String, String> map = new HashMap<String, String>();
        Iterator<String> it = obj.keys();
        while (it.hasNext()) {
            String key = String.valueOf(it.next());
            Object o = obj.get(key);
            if (o instanceof Integer) {
                String value = String.valueOf(o);
                map.put(key, value);
            } else if (o instanceof String) {
                String strValue = (String) o;
                map.put(key, strValue);
            }
        }
        MobclickAgent.onEvent(mContext, eventId, map);
    }

    @SuppressWarnings({ "unused" })
    private void onEventWithCounter(final JSONArray args) throws JSONException {
        Log.d("UMHybrid", "onEventWithCounter  args:" + args.toString());
        String eventId = args.getString(0);
        JSONObject obj = args.getJSONObject(1);
        Map<String, String> map = new HashMap<String, String>();
        Iterator<String> it = obj.keys();
        while (it.hasNext()) {
            String key = String.valueOf(it.next());
            Object o = obj.get(key);
            if (o instanceof Integer) {
                String value = String.valueOf(o);
                map.put(key, value);
            } else if (o instanceof String) {
                String strValue = (String) o;
                map.put(key, strValue);
            }
        }
        int value = args.getInt(2);
        MobclickAgent.onEventValue(mContext, eventId, map, value);
    }

    @SuppressWarnings({ "unused" })
    private void onPageBegin(final JSONArray args) throws JSONException {
        Log.d("UMHybrid", "onPageBegin  args:" + args.toString());
        String pageName = args.getString(0);
        MobclickAgent.onPageStart(pageName);
    }

    @SuppressWarnings({ "unused" })
    private void onPageEnd(final JSONArray args) throws JSONException {
        Log.d("UMHybrid", "onPageEnd  args:" + args.toString());
        String pageName = args.getString(0);
        MobclickAgent.onPageEnd(pageName);
    }

    @SuppressWarnings({ "unused" })
    private void profileSignInWithPUID(final JSONArray args) throws JSONException {
        Log.d("UMHybrid", "profileSignInWithPUID  args:" + args.toString());
        String puid = args.getString(0);
        MobclickAgent.onProfileSignIn(puid);
    }

    @SuppressWarnings({ "unused" })
    private void profileSignInWithPUIDWithProvider(final JSONArray args) throws JSONException {
        Log.d("UMHybrid", "profileSignInWithPUIDWithProvider  args:" + args.toString());
        String provider = args.getString(0);
        String uid = args.getString(1);
        MobclickAgent.onProfileSignIn(provider, uid);
    }

    @SuppressWarnings({ "unused" })
    private void profileSignOff(final JSONArray args) throws JSONException {
        Log.d("UMHybrid", "profileSignOff");
        MobclickAgent.onProfileSignOff();
    }

    @SuppressWarnings({ "unused" })
    private void onEventObject(final JSONArray args) throws JSONException {
        Log.d("UMHybrid", "onEventObject");
        String eventName = args.getString(0);
        JSONObject obj = args.getJSONObject(1);
        Map<String, Object> map = new HashMap<String, Object>();
        Iterator<String> it = obj.keys();
        while (it.hasNext()) {
            String key = String.valueOf(it.next());
            Object o = obj.get(key);
            map.put(key, o);
        }
        MobclickAgent.onEventObject(mContext, eventName, map);
    }

    @SuppressWarnings({ "unused" })
    private void registerPreProperties(final JSONArray args) throws JSONException {
        Log.d("UMHybrid", "registerPreProperties");
        for(int i=0 ; i < args.length() ;i++)
        {
            //获取每一个JsonObject对象
            MobclickAgent.registerPreProperties(mContext, args.getJSONObject(i));
        }

    }

    @SuppressWarnings({ "unused" })
    private void unregisterPreProperty(final JSONArray args) throws JSONException {
        Log.d("UMHybrid", "unregisterPreProperty");
        String propertyName = args.getString(0);
        MobclickAgent.unregisterPreProperty(mContext, propertyName);
    }

    private void clearPreProperties(final JSONArray args) throws JSONException {
        Log.d("UMHybrid", "clearPreProperties");
        MobclickAgent.clearPreProperties(mContext);
    }

    @SuppressWarnings({ "unused" })
    private void setFirstLaunchEvent(final JSONArray args) throws JSONException {
        Log.d("UMHybrid", "setFirstLaunchEvent");
        JSONArray array = args.getJSONArray(0);
        List<String> list = new ArrayList<String>();
        for (int i = 0; i < array.length(); i++) {
            list.add(array.getString(i));
        }
        MobclickAgent.setFirstLaunchEvent(mContext, list);
    }
}
