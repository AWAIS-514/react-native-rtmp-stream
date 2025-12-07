//
//  React Native RTMP Stream
//  Created by Nitensclue
//  https://nitensclue.com
//
package cn.nodemedia.react_native_nodemediaclient;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

public class RCTNodeMediaClient extends ReactContextBaseJavaModule {
    private static String mLicense = "";

    public RCTNodeMediaClient(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "RTMPStreamClient";
    }

    @ReactMethod
    public void setLicense(String license) {
        mLicense = license;
    }

    public static String getLicense() {
        return mLicense;
    }
}
