#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTLog.h>


@interface SpectrableModule : RCTEventEmitter <RCTBridgeModule, BleManagerDelegate>

@end
