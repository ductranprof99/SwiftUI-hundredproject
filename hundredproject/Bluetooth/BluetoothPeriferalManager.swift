//
//  BluetoothPeriferralManager.swift
//  hundredproject
//
//  Created by Duc Tran  on 3/8/25.
//

import CoreBluetooth

final class PeripheralManager: NSObject, CBPeripheralManagerDelegate {
    private var pm: CBPeripheralManager!
    private var commandChar: CBMutableCharacteristic!

    override init() {
        super.init()
        /// 2) Khởi tạo PM với identifier -> hỗ trợ state-restoration
        pm = CBPeripheralManager(delegate: self,
                                 queue: nil,
                                 options: [CBPeripheralManagerOptionRestoreIdentifierKey: "peripheral.pm"])
    }

    func peripheralManagerDidUpdateState(_ p: CBPeripheralManager) {
        guard p.state == .poweredOn else { return }

        /// 3) Tạo characteristic **write + notify**
        commandChar = CBMutableCharacteristic(
            type: BTConstants.commandCharUUID,
            properties: [.write, .notify],
            value: nil,
            permissions: [.writeable])

        /// 4) Tạo service, add characteristic
        let service = CBMutableService(type: BTConstants.serviceUUID, primary: true)
        service.characteristics = [commandChar]
        p.add(service)

        /// 5) Quảng bá với Service UUID để Central lọc nhanh
        p.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [BTConstants.serviceUUID],
            CBAdvertisementDataLocalNameKey: "iPhonePeripheral"])
    }

    /// 6) Nhận data từ Central
    func peripheralManager(_ p: CBPeripheralManager, didWrite requests: [CBATTRequest]) {
        for r in requests where r.characteristic.uuid == BTConstants.commandCharUUID {
            if let data = r.value, let text = String(data: data, encoding: .utf8) {
                print("⬅️ Central gửi: \(text)")
                let reply = Data("Đã nhận: \(text)".utf8)
                /// Gửi notify – nếu queue đầy, updateValue trả về false
                if !p.updateValue(reply, for: commandChar, onSubscribedCentrals: nil) {
                    // TODO: Ghi vào hàng đợi, gửi lại khi peripheralManagerIsReady(toUpdateSubscribers:)
                }
            }
            p.respond(to: r, withResult: .success)
        }
    }
}
