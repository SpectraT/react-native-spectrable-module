#import "SpectrableModule.h"

#define CInitSdkSuccess @"initSdkSuccess"
#define CInitSdkFailure @"initSdkFailure"

#define CStartScanSuccess @"startScanSuccess"
#define CStartScanFailure @"startScanFailure"

#define CStopScanSuccess @"stopScanSuccess"
#define CStopScanFailure @"stopScanFailure"

#define CMakePunchSuccess @"makePunchSuccess"
#define CMakePunchFailure @"makePunchFailure"

#define CGetDeviceListSuccess @"getDeviceListSuccess"
#define CGetDeviceListFailure @"getDeviceListFailure"

#define CMessage @"message"
#define CResponseCode @"response_code"
#define CDeviceList @"device_list"


@implementation SpectrableModule

RCT_EXPORT_MODULE()

static SpectraBLE *sharedInstance = nil;
bool hasListeners;

- (SpectraBLE *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [SpectraBLE alloc];
    });
    return sharedInstance;
}

// To initial BLE Sdk
RCT_EXPORT_METHOD(initSdk:(NSString * _Nonnull)apiURL apiKey:(NSString * _Nonnull)apiKey)
{
  [self sharedInstance].bleManagerDelegate = self;
  [[self sharedInstance] initSdkWithApiURL:apiURL apiKey:apiKey];
}

// Make punch with tag
RCT_EXPORT_METHOD(makePunch:(NSString * _Nonnull)tagId
                  destinationFloor:(NSInteger)destinationFloor
                  boardingFloor:(NSInteger)boardingFloor
                  selectedFloor:(NSInteger)selectedFloor
                  deviceUniqueId: (NSString * _Nonnull)deviceUniqueId)
{
  [[self sharedInstance] makePunchWithTagId:tagId
                           destinationFloor:destinationFloor
                              boardingFloor:boardingFloor
                              selectedFloor:selectedFloor
                             deviceUniqueId:deviceUniqueId];
}

// Start Scan
RCT_EXPORT_METHOD(startScan)
{
  [[self sharedInstance] startScan];
}


// Stop Scan
RCT_EXPORT_METHOD(stopScan)
{
  [[self sharedInstance] stopScan];
}

// GetDeviceList
RCT_EXPORT_METHOD(getDeviceList)
{
  [[self sharedInstance] getDeviceList];
}


- (void)startObserving {
    hasListeners = YES;
}

- (void)stopObserving {
    hasListeners = NO;
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[
            CInitSdkSuccess,
            CInitSdkFailure,
            CStartScanSuccess,
            CStartScanFailure,
            CStopScanSuccess,
            CStopScanFailure,
            CMakePunchSuccess,
            CMakePunchFailure,
            CGetDeviceListSuccess,
            CGetDeviceListFailure
         ];
}


#pragma mark - BleManager Delegate


- (void)onInitSuccessWithSuccessMsg:(NSString * _Nonnull)SuccessMsg {
  if (hasListeners) {
    [self sendEventWithName:CInitSdkSuccess body:@{CMessage: SuccessMsg,
                                                   CResponseCode: @(0)}];
  }
}

- (void)onInitFailureWithError:(BleSdkError * _Nonnull)error {
  
  if (hasListeners) {
    [self sendEventWithName:CInitSdkFailure body:@{CMessage: error.errorMessage,
                                                   CResponseCode: @(error.errorCode)}];
  }
}

- (void)onScanSuccessWithSuccessMsg:(NSString * _Nonnull)SuccessMsg {
  if (hasListeners) {
    [self sendEventWithName:CStartScanSuccess body:@{CMessage: SuccessMsg,
                                                     CResponseCode: @(0)}];
  }
}


- (void)onScanFailureWithError:(BleSdkError * _Nonnull)error {
  if (hasListeners) {
    [self sendEventWithName:CStartScanFailure body:@{CMessage: error.errorMessage,
                                                     CResponseCode: @(error.errorCode)}];
  }
}

- (void)onCommandSendSuccessWithSuccessMsg:(NSString * _Nonnull)SuccessMsg {
  if (hasListeners) {
    [self sendEventWithName:CMakePunchSuccess body:@{CMessage: SuccessMsg,
                                                     CResponseCode: @(0)}];
  }
}


- (void)onBleManagerFailureWithError:(BleSdkError * _Nonnull)error {
  if (hasListeners) {
    [self sendEventWithName:CMakePunchFailure body:@{CMessage: error.errorMessage,
                                                     CResponseCode: @(error.errorCode)}];
  }
}

- (void)onBleManagerSuccessWithSuccessMsg:(NSString * _Nonnull)SuccessMsg {
  if (hasListeners) {
    [self sendEventWithName:CMakePunchFailure body:@{CMessage: SuccessMsg,
                                                     CResponseCode: @(0)}];
  }
}

- (void)onGetDeviceListSuccessWithSuccessMsg:(NSString*  _Nonnull)SuccessMsg deviceArray:(NSMutableArray* _Nonnull)deviceArray {
  if (hasListeners) {
    [self sendEventWithName:CGetDeviceListSuccess body:@{CMessage: SuccessMsg,
                                                     CResponseCode: @(0),
                                                     CDeviceList: deviceArray
                                                   }];
  }
}

- (void)onGetDeviceListFailureWithError:(BleSdkError* _Nonnull)error {
  if (hasListeners) {
    [self sendEventWithName:CGetDeviceListFailure body:@{CMessage: error.errorMessage,
                                                     CResponseCode: @(error.errorCode)}];
  }
}


// Example method
// See // https://reactnative.dev/docs/native-modules-ios
RCT_REMAP_METHOD(multiply,
                 multiplyWithA:(nonnull NSNumber*)a withB:(nonnull NSNumber*)b
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
  NSNumber *result = @([a floatValue] * [b floatValue]);

  resolve(result);
}

@end
