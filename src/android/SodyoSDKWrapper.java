package org.apache.cordova.sodyosdk;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaInterface;

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

public class SodyoSDKWrapper extends CordovaPlugin {
    private static final int SODYO_SCANNER_REQUEST_CODE = 2222;

    private static final String TAG = "SodyoSDK";

    private Activity context;

    private CordovaInterface cordovaInterface;

    private class SodyoDetectCallback implements SodyoScannerCallback, SodyoInitCallback {

        private CallbackContext callbackContext;

        public SodyoDetectCallback(CallbackContext callbackContext) {
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
            callbackContext.error(err.toString());
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

        return false;
    }

    public void initialize(CordovaInterface cordovaInterface, CordovaWebView cordovaWebView) {
        super.initialize(cordovaInterface, cordovaWebView);

        Log.i(TAG, "initialize()");

        this.cordovaInterface = cordovaInterface;
        this.context = cordovaInterface.getActivity();
    }

    private void init(String apiKey, CallbackContext callbackContext) {
        Log.i(TAG, "init()");

        SodyoDetectCallback callbackClosure = new SodyoDetectCallback(callbackContext);

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
        SodyoDetectCallback callbackClosure = new SodyoDetectCallback(callbackContext);
        Intent intent = new Intent(this.context, SodyoScannerActivity.class);
        this.context.startActivityForResult(intent, SODYO_SCANNER_REQUEST_CODE);
        Sodyo.getInstance().setSodyoScannerCallback(callbackClosure);
    }

    private void close() {
        Log.i(TAG, "close()");
        this.context.finishActivity(SODYO_SCANNER_REQUEST_CODE);
    }
}
