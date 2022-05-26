//
//  BLE+Scanning.swift
//
//  Created by sft_mac on 21/02/22.
//

import Foundation
import CoreBluetooth

// MARK: -
// MARK: - Ble Scanning

extension SpectraBLE {
  
  public var state: CBManagerState {
    return self.centralManager?.state ?? .unknown
  }
  
  public var error: BleSdkError? {
    
    var scanError: BleSdkError? = nil
    
    switch state {
      
    case .poweredOn:
      return nil
      
    case .poweredOff:
      scanError = BLEErrorDesc.bluetoothOff
      
    case .unauthorized:
      scanError = BLEErrorDesc.bluetoothUnauthorized
      
//    case .unknown:
//      scanError = BLEErrorDesc.bluetoothUnknown
      
    case .resetting:
      scanError = BLEErrorDesc.bluetoothResetting
      
    case .unsupported:
      scanError = BLEErrorDesc.bluetoothUnsupported
      
    default:
      _ = ""
    }
    
    return scanError
  }
}



// MARK: -
// MARK: - Time Funtions

extension SpectraBLE {
  
  func startDeviceRemoveTimer() {
    
    if deviceRemoveTimer == nil {
      
      deviceRemoveTimer = Timer(timeInterval: 10.0, target: self, selector: #selector(timerFunction), userInfo: nil, repeats: true)
      
      RunLoop.current.add(deviceRemoveTimer!, forMode: .default)
    }
  }
  
  func stopDeviceRemoveTimer() {
    
    deviceRemoveTimer?.invalidate()
    deviceRemoveTimer = nil
  }
  
  @objc func timerFunction() {
    
    let arr = (self.scannedDevices as! [BLEDevice]) .filter { device in
      return Date().timeIntervalSince1970 - device.timestamp > 10
    }
    
    for obj in arr {
      
      let index = (scannedDevices as! [BLEDevice]).firstIndex(where: { obj1 in
        return obj1.peripheralId == obj.peripheralId
      })
      
      if index != nil {
        self.scannedDevices.removeObject(at: index!)
      }
    }
  }
}

