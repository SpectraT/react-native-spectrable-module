#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTLog.h>
#import "SpectraBLE-Swift.h"

@interface SpectrableModule : RCTEventEmitter <RCTBridgeModule, BleManagerDelegate>

@end
