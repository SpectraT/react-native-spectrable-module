//
//  BLE+Errors.swift
//  MyFirstFrameworkApp
//
//  Created by sft_mac on 21/02/22.
//

import Foundation

@objc
public class BleSdkError: NSObject {
    
    @objc public let errorCode: Int
    @objc public let errorMessage: String
    
    init(errorCode: Int, errorMessage: String) {
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}



public struct BLEErrorDesc {
    
    //Bluetooth scanning
    static let bluetoothOff = BleSdkError(errorCode: 1, errorMessage: BLEFailureMessage.turnOnBluetooth)
    static let bluetoothUnauthorized = BleSdkError(errorCode: 2, errorMessage: BLEFailureMessage.unauthorizedBluetoothState)
    static let bluetoothUnknown = BleSdkError(errorCode: 3, errorMessage: BLEFailureMessage.unknownBluetoothState)
    static let bluetoothResetting = BleSdkError(errorCode: 4, errorMessage: BLEFailureMessage.resettingBluetooth)
    static let bluetoothUnsupported = BleSdkError(errorCode: 5, errorMessage: BLEFailureMessage.unsupportedBluetooth)
    
    
    static let internetIsOff = BleSdkError(errorCode: 6, errorMessage: BLEFailureMessage.internetNotConnected)
    static let requestTimedOut = BleSdkError(errorCode: 7, errorMessage: BLEFailureMessage.requestTimedOut)
    static let technicalIssue = BleSdkError(errorCode: 8, errorMessage: BLEFailureMessage.serverConnectionFailed)
    static let noDeviceFound = BleSdkError(errorCode: 9, errorMessage: BLEFailureMessage.noDeviceFound)
    static let noDeviceFoundWithUniqueId = BleSdkError(errorCode: 23, errorMessage: BLEFailureMessage.noDeviceFoundWithUniqueId)
  
    static let connectionIsOngoing = BleSdkError(errorCode: 10, errorMessage:  BLEFailureMessage.connectionIsOngoing)
    static let scanningNotStarted = BleSdkError(errorCode: 11, errorMessage:  BLEFailureMessage.scanNotStarted)
    
    static let invalidURL = BleSdkError(errorCode: 12, errorMessage:  BLEFailureMessage.apiuUrlInvalid)
    static let initSdkFirst = BleSdkError(errorCode: 13, errorMessage: BLEFailureMessage.initSdkNotCalled)
}


public struct BLEFailureMessage {
    
    static let turnOnBluetooth = "Please turn your mobile bluetooth on to scan the bluetooth enabled devices"
    static let unauthorizedBluetoothState = "Unauthorised bluetooth state"
    static let unknownBluetoothState = "Unknown bluetooth state"
    static let resettingBluetooth = "Bluetooth is resetting"
    static let unsupportedBluetooth = "Bluetooth is not supported in your device"
    
    static let internetNotConnected = "You're not connected to the internet"
    static let requestTimedOut = "Server connection request timed out"
    static let serverConnectionFailed = "Could not connect to the server"
    static let noDeviceFound = "No bluetooth enabled device found nearby"
    static let noDeviceFoundWithUniqueId = "Device you want to connect is not found"
    static let connectionIsOngoing = "Previous bluetooth connection is still ongoing"
    static let scanNotStarted = "Bluetooth scanning is off, Please start scanning first to find the device nearby you"
    
    static let apiuUrlInvalid = "API URL is invalid, Please use a valid url and try again"
    static let initSdkNotCalled = "SDK has not been initialised yet, Please initialise the SDK first"
    
    static let failedToConnectPeripheral = "Could not connect to the device"
    
    static let failedToDiscoverCharacteristicForService = "Could not discover characteristic for a service"
    static let failedToDisconnectPeripheral = "Could not disconnect device"
    static let failedToDiscoverServices = "Could not discover services"
    static let failedToWriteValueForCharacteristic = "Could not write value for characteristic"
    static let failedToWriteValueForDescriptor = "Could not write value for descriptor"
    static let failedToUpdateValueForCharacteristic = "Could not update value for characteristic"
    static let failedToUpdateNotificationStateForCharacteristic = "Could not update notification state for characteristic"
}


public struct BLESuccessMessage {
    
    static let sdkInitializeSuccess = "SDK initialised successfully"
    static let scanningStarted = "Device scanning started successfully"
    
    static let peripheralConnected = "Peripheral connected successfully"
    static let peripheralDisconnected = "Peripheral disconnected successfully"
    static let serviceDiscoverySuccess = "Services discovered"
    static let characteristicValueWritten = "Characteristic value written successfully"
    static let descriptorValueWritten = "Descriptor value written successfully"
    static let characteristicValueUpdated = "Characteristic value udpdated successfully"
    static let characteristicNotificationStateUpdated = "Characteristic notification state updated successfully"
    static let characteristicDiscoveredForService = "Characteristic discovered for service successfully"
    static let commadSentSuccess = "Command sent to the device successfully"
    static let deviceListFetchedSuccess = "Device list fetched successfully"
}
