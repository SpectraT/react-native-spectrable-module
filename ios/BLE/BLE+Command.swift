//
//  BLE+Command.swift
//  MyFirstFrameworkApp
//
//  Created by sft_mac on 22/02/22.
//

import Foundation
import CoreBluetooth


extension SpectraBLE {
    
    func sendCommandOnDevice(characteristic: CBCharacteristic, peripheral: CBPeripheral) {
        
        guard let commandType = command else {
            return
        }
        
        var command: String?
       
        switch commandType {
                   
        // - - - - - - - - Set Punch Command:
        case Command.punch:
            command = BLEEncryption.punchCommand()
        }
        
        if let commanData = command?.data(using: .utf8) {
            peripheral.writeValue(commanData, for: characteristic, type: .withResponse)
            peripheral.delegate = self
        }
    }
    
    
   func disconnect() {
        
       guard let `connectedPeripheral` = connectedDevice?.peripheral else {
           return
       }
       
       centralManager?.cancelPeripheralConnection(connectedPeripheral)
    }
}
