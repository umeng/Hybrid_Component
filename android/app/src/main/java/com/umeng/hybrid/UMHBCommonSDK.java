package com.umeng.hybrid;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import android.content.Context;
import android.util.Log;
import com.umeng.commonsdk.UMConfigure;

/**
 * Created by wangfei on 17/9/28.
 * -- 适配(common 2.0.0 + analytics 8.0.0) modify by yujie on 18/12/28
 */

public class UMHBCommonSDK {
    public static void init(Context context, String appkey, String channel, int type, String secret){
        // 适配升级到2.0
        initHybrid("hybrid","2.0");
        UMConfigure.init(context,appkey,channel,type,secret);
    }
    public static void initHybrid(String v,String t){

        Method method = null;
        try {

            Class<?> config = Class.forName("com.umeng.commonsdk.UMConfigure");
            method = config.getDeclaredMethod("setWraperType", String.class, String.class);
            method.setAccessible(true);
            method.invoke(null, v,t);
            Log.e("xxxxxx","Set Hybrid WraperType failed.");
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
    public static void setLogEnabled(boolean able){

        UMConfigure.setLogEnabled(able);
    }

    // 子进程自定义事件埋点启用开关
    public static void setProcessEvent(boolean isEnable) {
        UMConfigure.setProcessEvent(isEnable);
    }

    // 报文是否加密启用开关
    public static void setEncryptEnabled(boolean bFlag) {
        UMConfigure.setEncryptEnabled(bFlag);
    }
}
