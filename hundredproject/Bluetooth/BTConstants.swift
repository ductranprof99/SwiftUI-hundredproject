//
//  BTConstants.swift
//  hundredproject
//
//  Created by Duc Tran  on 3/8/25.
//


//
// Constants.swift – đặt UUID cố định dùng chung
//
import CoreBluetooth

/// **1) Định nghĩa hằng** 128-bit cố định để Central & Peripheral chia sẻ
enum BTConstants {
    static let serviceUUID      = CBUUID(string: "12345678-ABCD-4321-ABCD-1234567890AB")
    static let commandCharUUID  = CBUUID(string: "12345678-ABCD-4321-ABCD-1234567890AC")
}