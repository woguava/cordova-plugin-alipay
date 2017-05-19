package com.openunion.cordova.plugins.alipay;

import android.text.TextUtils;
import android.util.Log;

import com.alipay.sdk.app.EnvUtils;
import com.alipay.sdk.app.PayTask;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.HashMap;
import java.util.Map;



/**
 * This class echoes a string called from JavaScript.
 */
public class AliPay extends CordovaPlugin {
  private final static String LOG_TAG = "openunion.alipay";
  private final static String APP_ID = "ALIPAY_APPID";
  private final static String TEST_MODE = "ALIPAY_TEST";
  
  /**
     * Payment mode, defaults to "00"
     *   * "00" => Official
     *   * "01" => Test
     */
  private static String g_TestMode = "00";
  private static String g_AppID = "";

  @Override
  public void pluginInitialize() {
    super.pluginInitialize();

    initMode();
  }

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    Log.d(LOG_TAG, "Execute:" + action + " with :" + args.toString());

    if (action.equals("starPay")) {
      String payParameters = (String) args.get(0);

      if(this.checkParamerValid(payParameters)){
        this.starPay(payParameters, callbackContext);
      }else{
        callbackContext.error("parameter error:" + args.get(0));
      }
    }else{
      return false;
    }

    return true;
  }

  private void starPay(final String orderInfo,final CallbackContext callbackContext) {
    Runnable payRunnable = new Runnable() {
      @Override
      public void run() {
        try {
          Log.d(LOG_TAG, "Calling Alipay with: " + orderInfo);
          // 构造PayTask 对象
          PayTask alipay = new PayTask(cordova.getActivity());

          if(g_TestMode.equals("01")){
            //设置沙箱测试,生产环境必须注释掉
            EnvUtils.setEnv(EnvUtils.EnvEnum.SANDBOX);
          } 

          // 调用支付接口，获取支付结果
          Map<String, String> rawResult = alipay.payV2(orderInfo, true);
          Log.d(LOG_TAG,"Alipay returns:" + rawResult.toString());

          final JSONObject resJson = getPayResult(rawResult);

          cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
              callbackContext.success(resJson.toString());
            }
          });
        }catch(Exception e){
          Log.e(LOG_TAG,"starPay Exception", e);
          callbackContext.error("Alipay Exception");
        }
      }
    };

    cordova.getThreadPool().execute(payRunnable);
  }

  //检测参数有效性
  private boolean checkParamerValid(String rawRequest) {
    if (rawRequest == null || rawRequest.isEmpty()) {
      return false;
    }
    Map<String,String> parameMap = new HashMap<String,String>();

    String[] paramArray = TextUtils.split(rawRequest,"&");
    int posIndex = -1;
    for(int i=0;i<paramArray.length;i++) {
      posIndex = paramArray[i].indexOf('=');
      if(posIndex == -1){
        continue;
      }
      parameMap.put(paramArray[i].substring(0,posIndex),paramArray[i].substring(posIndex+1));
    }

    if (!parameMap.containsKey("app_id") || !parameMap.containsKey("biz_content") 
      || !parameMap.containsKey("charset")  || !parameMap.containsKey("method")
      || !parameMap.containsKey("sign_type")  || !parameMap.containsKey("sign")
      || !parameMap.containsKey("timestamp")  || !parameMap.containsKey("version")
      || !parameMap.containsKey("notify_url") ) {
      return false;
    }

    return true;
  }

  //获取返回参数
  private JSONObject getPayResult(Map<String, String> rawResult) throws JSONException {
    JSONObject result = new JSONObject();
    if (rawResult == null) {
      return result;
    }

    for (String key : rawResult.keySet()) {
      if (TextUtils.equals(key, "resultStatus")) {
        result.put("resultStatus", rawResult.get(key));
      } else if (TextUtils.equals(key, "result")) {
        result.put("result", rawResult.get(key));
      } else if (TextUtils.equals(key, "memo")) {
        result.put("memo", rawResult.get(key));
      }
    }

    return result;
  }

  private void initMode() {
        g_TestMode = preferences.getString(TEST_MODE, "00");
        g_AppID = preferences.getString(APP_ID, "");

        Log.d(LOG_TAG, String.format("Initialized payment mode as %s.", g_TestMode));
    }

}
