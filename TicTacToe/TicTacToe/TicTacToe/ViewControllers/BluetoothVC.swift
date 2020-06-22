//
//  BluetoothVC.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 6/4/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import UIKit
import CoreBluetooth


class BluetoothVC: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    
    let BEAN_NAME = "Robu"
    let BEAN_SCRATCH_UUID =
      CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
    let BEAN_SERVICE_UUID =
      CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74de")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        manager = CBCentralManager(delegate: self, queue: nil)
    }

    @IBAction func clickBtn(_ sender: UIButton){
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
      } else {
        
        print("Bluetooth not available.")
      }
    }
    
    func centralManager(
      central: CBCentralManager,
      didDiscoverPeripheral peripheral: CBPeripheral,
      advertisementData: [String : AnyObject],
      RSSI: NSNumber) {
      let device = (advertisementData as NSDictionary)
        .object(forKey: CBAdvertisementDataLocalNameKey)
        as? NSString
            
        if device?.contains(BEAN_NAME) == true {
        self.manager.stopScan()
                
        self.peripheral = peripheral
        self.peripheral.delegate = self
                
            manager.connect(peripheral, options: nil)
      }
    }
    
    func centralManager(
      central: CBCentralManager,
      didConnectPeripheral peripheral: CBPeripheral) {
      peripheral.discoverServices(nil)
    }
    
    func peripheral(
      peripheral: CBPeripheral,
      didDiscoverServices error: NSError?) {
      for service in peripheral.services! {
        let thisService = service as CBService

        if service.uuid == BEAN_SERVICE_UUID {
            peripheral.discoverCharacteristics(
                nil,
                for: thisService
          )
        }
      }
    }
    
    func peripheral(
      peripheral: CBPeripheral,
      didDiscoverCharacteristicsForService service: CBService,
      error: NSError?) {
      for characteristic in service.characteristics! {
        let thisCharacteristic = characteristic as CBCharacteristic

        if thisCharacteristic.uuid == BEAN_SCRATCH_UUID {
            self.peripheral.setNotifyValue(
                true,
                for: thisCharacteristic
          )
        }
      }
    }
    
    func peripheral(
      peripheral: CBPeripheral,
      didUpdateValueForCharacteristic characteristic: CBCharacteristic,
      error: NSError?) {
      var count:UInt32 = 0;

    }
    
    func centralManager(
      central: CBCentralManager,
      didDisconnectPeripheral peripheral: CBPeripheral,
      error: NSError?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
}
