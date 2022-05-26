//
//
//  Created by Manoj on 25/01/22.
//

import Foundation
import CoreBluetooth

//MARK: -
//MARK: - Main Methods

extension SpectraBLE {
    
    //First call will be of INIT method
    
    @objc
    public func initSdk(apiURL: String, apiKey: String) {
        
        self.scannedDevices = NSMutableArray()
        
        if KeychainHelper.shared.value(forKey: DeviceConstant.CEncryptionKey) != nil {
            self.bleManagerDelegate?.onInitSuccess(SuccessMsg: BLESuccessMessage.sdkInitializeSuccess)
            return
        }
        
        let strUrl = apiURL.appending(APITag.facilityInit.rawValue)
        
        let request = MDLInitApiRequest(key: apiKey)
        
        guard let url = URL(string: strUrl) else {
            bleManagerDelegate?.onInitFailure(error: BLEErrorDesc.invalidURL)
            return
        }
        
        let requestBody = try! JSONEncoder().encode(request)
        
        let huRequest = HURequest(withUrl: url,
                                  forHttpMethod: .post,
                                  requestBody: requestBody)
        
        HttpUtility.shared.reqeuest(huRequest: huRequest,
                                    resultType: MDLInitApiResponse.self) { response in
            
            DispatchQueue.main.async {
                
                switch response {
                    
                case .success(let mdlInitApiResponse):
                    print("Response is: \(mdlInitApiResponse?.key ?? "No key saved")")
                    
                    if let `encryptionKey` = mdlInitApiResponse?.key {
                        KeychainHelper.shared.setValue(encryptionKey, forKey: DeviceConstant.CEncryptionKey)
                        self.bleManagerDelegate?.onInitSuccess(SuccessMsg: BLESuccessMessage.sdkInitializeSuccess)
                    }
                    
                case .failure(let huNetworkError):
                    
                    self.bleManagerDelegate?.onInitFailure(error: BleSdkError(
                        errorCode: 21,
                        errorMessage: "Error in initializing sdk: \(huNetworkError.reason ?? "Something went wrong, Please try again")")
                    )
                }
            }
        }
    }
    
    
    //2nd call will be of STARTSCAN method
    @objc
    public func startScan() {
        
        if self.centralManager == nil {
            
            self.centralManager = CBCentralManager(delegate: self,
                                                   queue: nil,
                                                   options: [
                                                    CBCentralManagerOptionShowPowerAlertKey: false
                                                   ])
        }
        
        if self.error != nil {
            bleManagerDelegate?.onScanFailure(error: error!)
            return
        }
        
        centralManager?.scanForPeripherals(withServices: [CBUUID(string: DeviceConstant.CDeviceUDID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        
        bleManagerDelegate?.onScanSuccess(successMsg: BLESuccessMessage.scanningStarted)
        
        startDeviceRemoveTimer()
    }
    
    
    //3rd call will be of STOPSCAN method
    @objc
    public func stopScan() {
        self.centralManager?.stopScan()
        stopDeviceRemoveTimer()
        self.centralManager = nil
        self.scannedDevices.removeAllObjects()
    }
    
    
    //4rd call will be of MAKEPUNCH method
    @objc
    public func makePunch(tagId: String,
                          destinationFloor: Int,
                          boardingFloor: Int,
                          selectedFloor: Int,
                          deviceUniqueId: String) {
        
        guard let key = KeychainHelper.shared.value(forKey: DeviceConstant.CEncryptionKey) else  {
            self.bleManagerDelegate?.onBleManagerFailure(error: BLEErrorDesc.initSdkFirst)
            return
        }
        
        if centralManager == nil {
            self.bleManagerDelegate?.onBleManagerFailure(error: BLEErrorDesc.scanningNotStarted)
            return
        }
        
        if scannedDevices.count == 0 {
            self.bleManagerDelegate?.onBleManagerFailure(error: BLEErrorDesc.noDeviceFound)
            return
        }
        
        var isIdEntered = false
        
        if deviceUniqueId.isBlank {
            
            let arrSorted = (scannedDevices as! [BLEDevice]) .sorted { device1, device2 in
                return device1.distance < device2.distance
            }
            
            connectedDevice = arrSorted[0]
            
        } else {
            
            isIdEntered = true
            
            let index = (scannedDevices as! [BLEDevice]).firstIndex { device in
                return device.peripheralId == deviceUniqueId
            }
            
            if index != nil {
                
                if scannedDevices.count > index! {
                    connectedDevice = (scannedDevices[index!] as! BLEDevice)
                }
                
            }
        }
        
        guard let `peripheralID` = connectedDevice?.peripheralId else {
            
            
            if isIdEntered {
                self.bleManagerDelegate?.onBleManagerFailure(error: BLEErrorDesc.noDeviceFoundWithUniqueId)
            } else {
                self.bleManagerDelegate?.onBleManagerFailure(error: BLEErrorDesc.noDeviceFound)
            }
            
            return
        }
        
        
        BLEEncryption.setEncryptionKey(key)
        BLEEncryption.setPeriphearalId(peripheralID)
        BLEEncryption.setTagId(tagId)
        BLEEncryption.setDestinationFloor("\(destinationFloor)")
        BLEEncryption.setBoardingFloor("\(boardingFloor)")
        BLEEncryption.setSelectedFloor("\(selectedFloor)")
        BLEEncryption.setDeviceType(connectedDevice?.deviceType ?? "")
        
        if let manufData = connectedDevice?.manufactureData {
            BLEEncryption.setDeviceData(manufData)
        }
        
        command = .punch
        
        guard let `peripheralToConnect` = connectedDevice?.peripheral else {
            return
        }
        
        centralManager?.connect(peripheralToConnect, options: nil)
    }
    
    @objc
    public func getDeviceList() {
        
        if centralManager == nil {
            bleManagerDelegate?.onGetDeviceListFailure(error: BLEErrorDesc.scanningNotStarted)
            return
        }
        
        let arrDevices = NSMutableArray()
        
        for device in (scannedDevices as! [BLEDevice]) {
            
            let dicDevice = NSMutableDictionary()
            
            dicDevice.setValue("\(device.deviceName ?? "")", forKey: "device_name")
            dicDevice.setValue("\(device.peripheralId ?? "")", forKey: "unique_id")
            
            arrDevices.add(dicDevice)
        }
        
        if arrDevices.count > 0 {
            bleManagerDelegate?.onGetDeviceListSuccess(successMsg: BLESuccessMessage.deviceListFetchedSuccess,
                                                       deviceArray: arrDevices)
        } else {
            
            bleManagerDelegate?.onGetDeviceListFailure(error: BLEErrorDesc.noDeviceFound)
        }
    }
    
    @objc
    public func removeKeychain() {
        
        if KeychainHelper.shared.value(forKey: DeviceConstant.CEncryptionKey) != nil {
            KeychainHelper.shared.removeValue(forKey: DeviceConstant.CEncryptionKey)
            return
        }
    }
    
    
}

