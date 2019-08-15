package org.apache.cordova.sodyosdk;

import android.graphics.Color;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import com.google.gson.Gson;
import org.apache.cordova.*;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;

import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;

import com.sodyo.sdk.Sodyo;
import com.sodyo.sdk.SodyoInitCallback;
import com.sodyo.sdk.SodyoScannerActivity;
import com.sodyo.sdk.SodyoScannerCallback;

import java.util.Map;

public class SodyoSDKWrapper extends CordovaPlugin {
    private static final int SODYO_SCANNER_REQUEST_CODE = 2222;

    private static final String TAG = "SodyoSDK";

    private Activity context;

    private CordovaInterface cordovaInterface;

    private CallbackContext eventCallbackContext;

    private class SodyoCallback implements SodyoScannerCallback, SodyoInitCallback {

        private CallbackContext callbackContext;

        public SodyoCallback(CallbackContext callbackContext) {
            this.callbackContext = callbackContext;
        }

        /**
         * SodyoInitCallback implementation
         */
        public void onSodyoAppLoadSuccess() {
            String message = "onSodyoAppLoadSuccess";
            Log.i(TAG, message);
            callbackContext.success();
        }

        /**
         * SodyoInitCallback implementation
         */
        public void onSodyoAppLoadFailed(String error) {
            String message = "onSodyoAppLoadFailed. Error=\"" + error + "\"";
            Log.e(TAG, message);
            callbackContext.error(error);
        }

        /**
         * SodyoInitCallback implementation
         */
        @Override
        public void sodyoError(Error err) {
            String message = "sodyoError. Error=\"" + err + "\"";
            Log.e(TAG, message);

            if (eventCallbackContext != null) {
                PluginResult result = new PluginResult(
                        PluginResult.Status.OK,
                        "sodyoError"
                );
                result.setKeepCallback(true);
                eventCallbackContext.sendPluginResult(result);
            }
        }

        /**
         * SodyoScannerCallback implementation
         */
        @Override
        public void onMarkerDetect(String markerType, String data, String error) {
            if (data == null) {
                data = "null";
            }

            String message;

            if (error == null) {
                message = "SodyoScannerCallback.onMarkerDetect  data=\"" + data + "\"";
                Log.i(TAG, message);
                callbackContext.success(data);
            } else {
                message = "SodyoScannerCallback.onMarkerDetect  data=\"" + data + "\" error=\"" + error + "\"";
                Log.e(TAG, message);
                callbackContext.error(error);
            }
        }
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("registerCallback")) {
            this.registerCallback(callbackContext);
            return true;
        }

        if (action.equals("start")) {
            this.start(callbackContext);
            return true;
        }

        if (action.equals("init")) {
            this.init(args.getString(0), callbackContext);
            return true;
        }

        if (action.equals("close")) {
            this.close();
            return true;
        }

        if (action.equals("setUserInfo")) {
            if (args.getJSONObject(0) == null) {
                return false;
            }

            Map userInfo = new Gson().fromJson(args.getJSONObject(0).toString(), Map.class);
            this.setUserInfo(userInfo);
            return true;
        }

        if (action.equals("setCustomAdLabel")) {
            this.setCustomAdLabel(args.getString(0));
            return true;
        }

        if (action.equals("setAppUserId")) {
            this.setAppUserId(args.getString(0));
            return true;
        }

        if (action.equals("setScannerParams")) {
            if (args.getJSONObject(0) == null) {
                return false;
            }

            Map scannerPreferences = new Gson().fromJson(args.getJSONObject(0).toString(), Map.class);
            this.setScannerParams(scannerPreferences);
            return true;
        }

        if (action.equals("setOverlayView")) {
            this.setOverlayView(args.getString(0));
            return true;
        }

        return false;
    }

    public void initialize(CordovaInterface cordovaInterface, CordovaWebView cordovaWebView) {
        super.initialize(cordovaInterface, cordovaWebView);

        Log.i(TAG, "initialize()");

        this.cordovaInterface = cordovaInterface;
        this.context = cordovaInterface.getActivity();
    }

    private void registerCallback(CallbackContext callbackContext) {
        Log.i(TAG, "registerCallback()");
        this.eventCallbackContext = callbackContext;

        PluginResult result = new PluginResult(
                PluginResult.Status.OK,
                "registered"
        );
        result.setKeepCallback(true);
        this.eventCallbackContext.sendPluginResult(result);
    }

    private void init(String apiKey, CallbackContext callbackContext) {
        Log.i(TAG, "init()");

        SodyoCallback callbackClosure = new SodyoCallback(callbackContext);

        this.context.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Sodyo.init(
                        (Application) cordovaInterface.getContext().getApplicationContext(),
                        apiKey,
                        callbackClosure
                );
            }
        });
    }

    private void start(CallbackContext callbackContext) {
        Log.i(TAG, "start()");
        SodyoCallback callbackClosure = new SodyoCallback(callbackContext);
        Intent intent = new Intent(this.context, SodyoScannerActivity.class);
        this.context.startActivityForResult(intent, SODYO_SCANNER_REQUEST_CODE);
        Sodyo.getInstance().setSodyoScannerCallback(callbackClosure);
    }

    private void close() {
        Log.i(TAG, "close()");
        this.context.finishActivity(SODYO_SCANNER_REQUEST_CODE);
    }

    private void setUserInfo(Map<String, ?> userInfo) {
        Log.i(TAG, "setUserInfo()");
        Sodyo.setUserInfo(userInfo);
    }

    private void setCustomAdLabel(String label) {
        Log.i(TAG, "setCustomAdLabel()");
        Sodyo.setCustomAdLabel(label);
    }

    private void setAppUserId(String userId) {
        Log.i(TAG, "setAppUserId()");
        Sodyo.setAppUserId(userId);
    }

    private void setScannerParams(Map<String, ?> scannerPreferences) {
        Log.i(TAG, "setScannerParams()");
        Sodyo.setScannerParams(scannerPreferences);
    }

    private void setOverlayView(String html) {
        Log.i(TAG, "setOverlayView()");

        this.context.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                WebView webView = new WebView(cordovaInterface.getContext());
                webView.loadDataWithBaseURL("", html, "text/html", "UTF-8", "");
                webView.setBackgroundColor(Color.TRANSPARENT);
                webView.setWebViewClient(new WebViewClient() {
                    @Override
                    public boolean shouldOverrideUrlLoading(WebView view, String url) {
                        String[] parsedUrl = url.split("sodyosdk://");

                        if (parsedUrl.length >= 2) {
                            callOverlayCallback(parsedUrl[1]);
                        }

                        return true;
                    }
                });
                Sodyo.setOverlayView(webView);
            }
        });
    }

    private void callOverlayCallback(String callbackName) {
        Log.i(TAG, "callOverlayCallback()");

        if (eventCallbackContext == null) {
            return;
        }

        PluginResult result = new PluginResult(
                PluginResult.Status.OK,
                callbackName
        );
        result.setKeepCallback(true);
        this.eventCallbackContext.sendPluginResult(result);
    }
}
