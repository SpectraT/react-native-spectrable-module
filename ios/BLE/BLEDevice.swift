//
//  File.swift
//
//
//  Created by Manoj on 21/01/22.
//

import Foundation
import CoreBluetooth

public struct BLEDevice: Equatable {

    private enum Advertise {

        case transantionLevel
        case manufactureData
        case advDataServiceUUIDs
        case advDataLocalName
        case deviceType

        var text: String {

            switch self {

            case .transantionLevel:
                return "kCBAdvDataTxPowerLevel"

            case .manufactureData:
                return "kCBAdvDataManufacturerData"

            case .advDataServiceUUIDs:
                return "kCBAdvDataServiceUUIDs"

            case .advDataLocalName:
                return "kCBAdvDataLocalName"

            case .deviceType:
                return "devicetype"
            }
        }
    }

    public let peripheral: CBPeripheral?
    public let advertisementData: [String: Any]?
    public let rssi: Int?
    public var rssiHistory: [Int]
    public var timestamp: Double
    public var isConnected: Bool = false

    public init(peripheral: CBPeripheral?,
                advertisementData: [String: Any]? = nil,
                rssi: Int?,
                timestamp: Double,
                rssiHistory: [Int] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
                ) {

        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.rssi = rssi
        self.timestamp = timestamp
        self.rssiHistory = rssiHistory
    }

    public static func == (lhs: BLEDevice, rhs: BLEDevice) -> Bool {
        return lhs.peripheralId == rhs.peripheralId
    }

    public var IsXPReader: Bool {

        if self.deviceType == DeviceType.XPReader.rawValue || self.deviceType == DeviceType.XPReader2.rawValue {
            return true
        }

        return false
    }

    public var midPoint: Int? {

        if self.rssiHistory.count == 0 {
            return self.rssi
        }

        let arrHistorySorted = self.rssiHistory.sorted()

        if arrHistorySorted.count < 8 && arrHistorySorted.count > 1 {

            let value = arrHistorySorted[1]

            if value != 0 {
                return value
            }

            return self.rssi
        }

        if arrHistorySorted[6] == 0 || arrHistorySorted[7] == 0 {
            return self.rssi
        }

        return (arrHistorySorted[6] + arrHistorySorted[7])/2
    }

    public var distance: Double {

        var rssi = DeviceParameter.XP_RSSI.rawValue

        if !self.IsXPReader {
            rssi = DeviceParameter.OTHER_RSSI.rawValue
        }

        let sensitivity = 2.0

        let midPoint = self.midPoint ?? 0

        let x: Double = (Double(rssi) - Double(midPoint)) / (10*sensitivity)

        return pow(10.0, x)*100.0
    }

    public var manufactureData: Data? {

        guard let manufData = self.advertisementData?[Advertise.manufactureData.text] as? Data else {
            return nil
        }

        return manufData
    }

    public var manufDataString: String? {

        if let data = manufactureData as NSData? {

            if let result = data.hexRepresentationWithSpaces_AS() {
                return result
            }
        }

        return nil
    }

    public var deviceName: String? {

        guard let name = self.advertisementData?[Advertise.advDataLocalName.text] as? String else {
            return nil
        }
        return name
    }

    public var peripheralId: String? {
        return self.peripheral?.identifier.uuidString
    }

    public var inOutFlag: String? {

        guard let count = manufDataString?.count, count > 10 else {
            return nil
        }

        return manufDataString?.substring(with: 8..<10)
    }

    public var deviceType: String? {

        guard let count = manufDataString?.count, count > 12 else {
            return nil
        }

        return manufDataString?.substring(with: 10..<12)
    }

    public var transactionLevel: Int? {

        guard let result = self.advertisementData?[Advertise.advDataLocalName.text] as? Int else {
            return nil
        }

        return result
    }
}



