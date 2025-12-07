//
//  React Native RTMP Stream
//  Created by Nitensclue
//  https://nitensclue.com
//
package cn.nodemedia.react_native_nodemediaclient;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.List;

public class RCTNodeMediaClientPackage implements ReactPackage {
    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        return List.of(new RCTNodeMediaClient(reactContext));
    }

    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        return List.of(new RCTNodePlayerManager(), new RCTNodePublisherManager());
    }
}
