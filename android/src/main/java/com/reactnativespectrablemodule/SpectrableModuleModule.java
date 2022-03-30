package com.reactnativespectrablemodule;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.spectra.mobile_access.api.GetDeviceListListener;
import com.spectra.mobile_access.api.InitSdkListener;
import com.spectra.mobile_access.api.MakePunchListener;
import com.spectra.mobile_access.api.SdkResponse;
import com.spectra.mobile_access.api.SpectraApi;
import com.spectra.mobile_access.api.StartScanningListener;
import com.spectra.mobile_access.api.StopScanningListener;

import java.util.Map;

@ReactModule(name = SpectrableModuleModule.NAME)
public class SpectrableModuleModule extends ReactContextBaseJavaModule {
  public static final String NAME = "SpectrableModule";

  private static final String SUCCESS_POSTFIX = "Success";
  private static final String FAILURE_POSTFIX = "Failure";

  private static final String KEY_DEVICE_NAME = "device_name";
  private static final String KEY_DEVICE_ID = "unique_id";
  private static final String KEY_DEVICE_LIST = "device_list";
  private static final String KEY_MESSAGE = "message";
  private static final String KEY_RESPONSE_CODE = "response_code";

  public SpectrableModuleModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }


  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  public void multiply(int a, int b, Promise promise) {
    promise.resolve(a * b);
  }

  public static native int nativeMultiply(int a, int b);

  /* Call everytime when app gets opened */
  @ReactMethod
  public void initSdk(String apiURL, String apiKey) {
    String eventName = "initSdk";
    SpectraApi.init(getReactApplicationContext(), apiURL, apiKey, new InitSdkListener() {
      @Override
      public void onInitSuccess(SdkResponse sdkResponse) {
        sendEvent(eventName + SUCCESS_POSTFIX, sdkResponse);
      }

      @Override
      public void onInitError(SdkResponse sdkResponse) {
        sendEvent(eventName + FAILURE_POSTFIX, sdkResponse);
      }
    });
  }

  /* Call when app comes in foreground */
  @ReactMethod
  public void startScan() {
    String eventName = "startScan";
    SpectraApi.startScanning(getReactApplicationContext(), new StartScanningListener() {
      @Override
      public void onScanningStarted(SdkResponse sdkResponse) {
        sendEvent(eventName + SUCCESS_POSTFIX, sdkResponse);
      }

      @Override
      public void onScanningError(SdkResponse sdkResponse) {
        sendEvent(eventName + FAILURE_POSTFIX, sdkResponse);
      }
    });
  }

  /* Call when app goes to background */
  @ReactMethod
  public void stopScan() {
    String eventName = "stopScan";
    SpectraApi.stopScanning(getReactApplicationContext(), new StopScanningListener() {
      @Override
      public void onScanningStopped(SdkResponse sdkResponse) {
        sendEvent(eventName + SUCCESS_POSTFIX, sdkResponse);
      }

      @Override
      public void onScanningStopError(SdkResponse sdkResponse) {
        sendEvent(eventName + FAILURE_POSTFIX, sdkResponse);
      }
    });
  }

  /* Get nearby device list */
  @ReactMethod
  public void getDeviceList() {
    String eventName = "getDeviceList";
    SpectraApi.getDeviceList(getReactApplicationContext(), new GetDeviceListListener() {
      @Override
      public void onDeviceListFetchSuccess(SdkResponse sdkResponse, Map<String, String> deviceList) {
        sendEventWithMap(eventName + SUCCESS_POSTFIX, sdkResponse, deviceList);
      }

      @Override
      public void onDeviceListFetchFailure(SdkResponse sdkResponse) {
        sendEvent(eventName + FAILURE_POSTFIX, sdkResponse);
      }
    });
  }

  /* Make A Punch */
  @ReactMethod
  public void makePunch(String tagId, int destinationFloor, int boardingFloor, int selectedFloor, String uniqueId) {
    String eventName = "makePunch";
    SpectraApi.makePunch(getReactApplicationContext(), tagId, selectedFloor, boardingFloor, destinationFloor, uniqueId, new MakePunchListener() {
      @Override
      public void onRequestSuccess(SdkResponse sdkResponse) {
        sendEvent(eventName + SUCCESS_POSTFIX, sdkResponse);
      }

      @Override
      public void onRequestError(SdkResponse sdkResponse) {
        sendEvent(eventName + FAILURE_POSTFIX, sdkResponse);
      }
    });
  }

  private void sendEvent(String eventName, SdkResponse sdkResponse) {
    WritableMap params = Arguments.createMap();
    params.putInt(KEY_RESPONSE_CODE, sdkResponse.getResponseCode());
    params.putString(KEY_MESSAGE, sdkResponse.getMessage());
    getReactApplicationContext()
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
      .emit(eventName, params);
  }

  private void sendEventWithMap(String eventName, SdkResponse sdkResponse, Map<String, String> deviceList) {
    WritableMap params = Arguments.createMap();
    params.putInt(KEY_RESPONSE_CODE, sdkResponse.getResponseCode());
    params.putString(KEY_MESSAGE, sdkResponse.getMessage());

    WritableArray paramsDevices = Arguments.createArray();
    for (Map.Entry<String, String> entry : deviceList.entrySet()) {
      WritableMap singleDevice = Arguments.createMap();
      singleDevice.putString(KEY_DEVICE_ID, entry.getKey());
      singleDevice.putString(KEY_DEVICE_NAME, entry.getValue());
      paramsDevices.pushMap(singleDevice);
    }
    params.putArray(KEY_DEVICE_LIST, paramsDevices);

    getReactApplicationContext()
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
      .emit(eventName, params);
  }


}
