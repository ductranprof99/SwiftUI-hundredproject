//
//  BluetoothCentralManager.swift
//  hundredproject
//
//  Created by Duc Tran  on 3/8/25.
//

import CoreBluetooth

final class CentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var cm: CBCentralManager!
    private var target: CBPeripheral?

    override init() {
        super.init()
        cm = CBCentralManager(delegate: self,
                              queue: nil,
                              options: [CBCentralManagerOptionRestoreIdentifierKey: "central.cm"])
    }

    // 1) Đợi radio BLE sẵn sàng rồi bắt đầu scan Service UUID đã biết
    func centralManagerDidUpdateState(_ cm: CBCentralManager) {
        guard cm.state == .poweredOn else { return }
        cm.scanForPeripherals(withServices: [BTConstants.serviceUUID])
    }

    // 2) Phát hiện peripheral
    func centralManager(_ cm: CBCentralManager, didDiscover p: CBPeripheral,
                        advertisementData: [String : Any], rssi: NSNumber) {
        self.cm.stopScan()
        target = p
        p.delegate = self

        // 3) Kết nối (tự động reconnect nếu iOS 17+)
        if #available(iOS 17.0, *) {
            cm.connect(p, options: [CBConnectPeripheralOptionEnableAutoReconnect: true])
        } else {
            cm.connect(p, options: nil) // Fallback cho iOS 16 trở xuống
        }
    }

    // 4) Sau khi kết nối, discover service
    func centralManager(_ cm: CBCentralManager, didConnect p: CBPeripheral) {
        p.discoverServices([BTConstants.serviceUUID])
    }

    // 5) Sau khi tìm được service -> tìm characteristic
    func peripheral(_ p: CBPeripheral, didDiscoverServices error: Error?) {
        guard let s = p.services?.first else { return }
        p.discoverCharacteristics([BTConstants.commandCharUUID], for: s)
    }

    // 6) Subcribe notify + gửi gói "Hello-BLE"
    func peripheral(_ p: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let ch = service.characteristics?.first else { return }
        p.setNotifyValue(true, for: ch)
        p.writeValue(Data("Hello-BLE".utf8), for: ch, type: .withResponse)
    }

    // 7) Nhận notify
    func peripheral(_ p: CBPeripheral, didUpdateValueFor ch: CBCharacteristic, error: Error?) {
        if let v = ch.value { print("⬅️ Peripheral phản hồi: \(String(decoding: v, as: UTF8.self))") }
    }

    // 8) Nếu OS ngắt, tự reconnect (backup cho auto-reconnect)
    func centralManager(_ cm: CBCentralManager, didDisconnectPeripheral p: CBPeripheral, error: Error?) {
        if #available(iOS 17.0, *) {
            cm.connect(p, options: [CBConnectPeripheralOptionEnableAutoReconnect: true])
        } else {
            cm.connect(p, options: nil) // Thủ công reconnect cho iOS 16-
        }
    }
}
