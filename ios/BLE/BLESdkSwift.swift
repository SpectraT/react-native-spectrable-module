//
//  BLESdkSwift.swift
//  BleSdkSwift
//
//  Created by Manoj on 29/01/22.
//

import CoreBluetooth

@objc
public class SpectraBLE: NSObject {
  
  public static let shared = SpectraBLE()
  
  override private init() {
    super.init()
  }
  
  @objc public weak var bleManagerDelegate: BleManagerDelegate?
  
  var deviceRemoveTimer: Timer?
  var command: Command?
  var connectedDevice: BLEDevice?
  
  @objc public var scannedDevices: NSMutableArray = [BLEDevice]() as! NSMutableArray
  
  var isConnectionOngoing: Bool = false
  
  lazy var centralManager: CBCentralManager? = nil
}
