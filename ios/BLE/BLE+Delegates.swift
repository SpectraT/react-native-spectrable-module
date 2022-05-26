//
//
//  Created by Manoj on 11/01/22.
//

import Foundation
import CoreBluetooth


//MARK: - BLE central manager delegate methods
//MARK: -

extension SpectraBLE: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
      if central.state == .poweredOn {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          self.startScan()
        }
      }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if RSSI.intValue > 50 {
            return
        }
        
        let device = BLEDevice(peripheral: peripheral,
                               advertisementData: advertisementData,
                               rssi: RSSI.intValue,
                               timestamp: Date().timeIntervalSince1970,
                               rssiHistory: [RSSI.intValue,
                                             0,
                                             0,
                                             0,
                                             0,
                                             0,
                                             0,
                                             0,
                                             0,
                                             0,
                                             0,
                                             0,
                                             0,
                                             0,
                                             0
                                            ])

        if scannedDevices.count == 0 {

            //Add new device
          scannedDevices.add(device)

        } else {

            //Scanned list is not empty

          let arr = (scannedDevices as! [BLEDevice]) .filter { obj in
            return obj.peripheralId == device.peripheralId
          }
          
          if arr.count == 0 {
            //Add new device
            scannedDevices.add(device)
            
          } else {
            
            let index = (scannedDevices as! [BLEDevice]).firstIndex(where: { obj in
              return device.peripheralId == obj.peripheralId
            })
                
            if index != nil {
              
              if var foundDevice = scannedDevices[index!] as? BLEDevice {
                
                var arrHistory = foundDevice.rssiHistory
                arrHistory.insert(RSSI.intValue, at: 0)
                
                if arrHistory.count > DeviceConstant.CReadingCount {
                  arrHistory.removeLast()
                }
                
                foundDevice.rssiHistory = arrHistory
                
                if scannedDevices.count > index! {
                  scannedDevices[index!] = foundDevice
                }
                
              }
            }
          }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        isConnectionOngoing = false
        
        if peripheral.state == .connected {
            //connectedPeripheral = peripheral
            //vibrate phone
        }
        
        peripheral.delegate = self
        
        if let connectedDevice = connectedDevice, connectedDevice.IsXPReader {

            if peripheral.services != nil {
                self.peripheral(peripheral, didDiscoverServices: nil)
            } else {
                peripheral.discoverServices([CBUUID(string: DeviceConstant.CServiceUuidXPReader)])
            }

            return
        }
        
        if peripheral.services != nil {
            self.peripheral(peripheral, didDiscoverServices: nil)
        } else {
            peripheral.discoverServices([CBUUID(string: DeviceConstant.CServiceUuid)])
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        if error != nil {
            
            bleManagerDelegate?.onBleManagerFailure(error: BleSdkError(
                errorCode: 22,
                errorMessage: error?.localizedDescription ?? BLEFailureMessage.failedToConnectPeripheral))
        }
        
        isConnectionOngoing = false
        startScan()
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        if error != nil {
            
//            bleManagerDelegate?.onBleManagerFailure(error: BleSdkError(
//                errorCode: 14,
//                errorMessage: error?.localizedDescription ?? BLEFailureMessage.failedToDisconnectPeripheral))
            
            return
        }
        
//        bleManagerDelegate?.onBleManagerSuccess(successMsg: BLESuccessMessage.peripheralDisconnected)
        isConnectionOngoing = false
    }
    
    public func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
        
    }
}


//MARK: - BLE peripheral delegate methods
//MARK: -

extension SpectraBLE: CBPeripheralDelegate {
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
//        if error != nil {
//
//            bleManagerDelegate?.onBleManagerFailure(error: BleSdkError(
//                errorCode: 15,
//                errorMessage: error?.localizedDescription ?? BLEFailureMessage.failedToDiscoverServices))
//
//            return
//        }

        if let pServices = peripheral.services {

            for service in pServices {

                if let connectedDevice = connectedDevice, connectedDevice.IsXPReader {

                    peripheral.discoverCharacteristics([CBUUID(string: DeviceConstant.CCharacteristicUuidXPReader), CBUUID(string: DeviceConstant.CCharacteristicUuidForResponseXPReader)], for: service)

//                    bleManagerDelegate?.onBleManagerSuccess(successMsg: BLESuccessMessage.serviceDiscoverySuccess)

                } else {

                    peripheral.discoverCharacteristics([CBUUID(string: DeviceConstant.CCharacteristicUuidForResponse), CBUUID(string: DeviceConstant.CCharacteristicUuid)], for: service)

//                    bleManagerDelegate?.onBleManagerSuccess(successMsg: BLESuccessMessage.serviceDiscoverySuccess)
                }
           }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
//        if error != nil {
//
//            bleManagerDelegate?.onBleManagerFailure(error: BleSdkError(
//                errorCode: 16,
//                errorMessage: error?.localizedDescription ?? BLEFailureMessage.failedToDiscoverCharacteristicForService))
//
//            return
//        }
        
        guard let arrChars = service.characteristics else {
            return
        }
        
//        bleManagerDelegate?.onBleManagerSuccess(successMsg: BLESuccessMessage.characteristicDiscoveredForService)
        
        for characteristic in arrChars {
            
            if let connectedDevice = connectedDevice, connectedDevice.IsXPReader {
                
                if characteristic.uuid == CBUUID(string: DeviceConstant.CCharacteristicUuidXPReader) {
                    
                    peripheral.setNotifyValue(true, for: characteristic)
                    sendCommandOnDevice(characteristic: characteristic, peripheral: peripheral)
                    
                } else if characteristic.uuid == CBUUID(string: DeviceConstant.CCharacteristicUuidForResponseXPReader) {
                    
                    peripheral.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                    
                }
                
            } else {
                
                if characteristic.uuid == CBUUID(string: DeviceConstant.CCharacteristicUuid) {
                    
                    peripheral.setNotifyValue(true, for: characteristic)
                    sendCommandOnDevice(characteristic: characteristic, peripheral: peripheral)
                    
                } else if characteristic.uuid == CBUUID(string: DeviceConstant.CCharacteristicUuidForResponse) {
                    
                    peripheral.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                    
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
//        if error != nil {
//
//            bleManagerDelegate?.onBleManagerFailure(error: BleSdkError(
//                errorCode: 17,
//                errorMessage: error?.localizedDescription ?? BLEFailureMessage.failedToWriteValueForCharacteristic))
//
//            return
//        }
        
        bleManagerDelegate?.onCommandSendSuccess(successMsg: BLESuccessMessage.commadSentSuccess)
        
        isConnectionOngoing = false
        if peripheral.state == .connected {
            disconnect()
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        
//        if error != nil {
//
//            bleManagerDelegate?.onBleManagerFailure(error: BleSdkError(
//                errorCode: 18,
//                errorMessage: error?.localizedDescription ?? BLEFailureMessage.failedToWriteValueForDescriptor))
//
//            return
//        }
        
//        bleManagerDelegate?.onBleManagerSuccess(successMsg: BLESuccessMessage.descriptorValueWritten)
        
        isConnectionOngoing = false
        
        if peripheral.state == .connected {
            disconnect()
        }
    }
        
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
     
//        if error != nil {
//
//            bleManagerDelegate?.onBleManagerFailure(
//                error: BleSdkError(errorCode: 19,
//                                   errorMessage: error?.localizedDescription ?? BLEFailureMessage.failedToUpdateValueForCharacteristic))
//
//            return
//        }
        
        
//        bleManagerDelegate?.onBleManagerSuccess(successMsg: BLESuccessMessage.characteristicValueUpdated)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
//        if error != nil {
//
//            bleManagerDelegate?.onBleManagerFailure(error: BleSdkError(
//                errorCode: 20,
//                errorMessage: error?.localizedDescription ?? BLEFailureMessage.failedToUpdateNotificationStateForCharacteristic))
//        }
//
//        bleManagerDelegate?.onBleManagerSuccess(successMsg: BLESuccessMessage.characteristicNotificationStateUpdated)
    }
}

//MARK: - BLE peripheral manager delegate methods
//MARK: -
extension SpectraBLE: CBPeripheralManagerDelegate {
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
            
    }
        
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
    }
}
