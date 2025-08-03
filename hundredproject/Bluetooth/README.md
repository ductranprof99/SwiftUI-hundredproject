# Tài liệu kỹ thuật: Bluetooth trên iOS — Cơ chế, giới hạn, kiến trúc & mã mẫu

**Mục tiêu:** Tổng hợp ngắn gọn nhưng đầy đủ về cách xây dựng ứng dụng tùy biến quanh Bluetooth trên iOS: hiểu cơ chế BLE (GATT), cách kết nối 2 thiết bị iOS, khi nào dùng Multipeer Connectivity, Nearby Interaction (UWB), và External Accessory (MFi). Bao gồm từ khóa quan trọng, giải thích “vì sao gọi như vậy”, guideline thiết kế giao thức riêng, và mã mẫu khởi đầu.

---

## 0) Từ khóa chính (keywords — chỉ cụm ngắn)
- *CoreBluetooth*, *CBCentralManager*, *CBPeripheralManager*, *CBService*, *CBCharacteristic*, *GATT*, *Advertisement*, *Notify*, *Write With/Without Response*, *MTU*
- *MultipeerConnectivity*, *MCPeerID*, *MCSession*, *MCNearbyServiceAdvertiser*, *MCNearbyServiceBrowser*
- *NearbyInteraction* (UWB), *Discovery token*
- *ExternalAccessory* (MFi), *EAAccessory*, *EASession*, *iAP2*
- *Background modes* (Bluetooth LE accessories), *Entitlement*

> Bảng trên chỉ chứa **cụm ngắn**. Mọi giải thích chi tiết nằm ở phần thân tài liệu.

---

## 1) Tổng quan & giới hạn truy cập phần cứng trên iOS

- iOS **không** cho truy cập radio Bluetooth ở mức HCI/packet raw. Bạn **không** can thiệp trực tiếp công suất phát, nhảy kênh, hay sniffing gói tin. Thay vào đó, bạn làm việc qua **framework cấp cao**:
  - **CoreBluetooth**: cho **Bluetooth Low Energy (BLE)** theo chuẩn **GATT** (Generic Attribute Profile). Bạn có thể đóng vai **Central** (quét/kết nối) hoặc **Peripheral** (quảng bá/đáp ứng).
  - **Multipeer Connectivity (MPC)**: lớp ngang (overlay) **tự chọn** đường truyền cục bộ (Bluetooth, Wi‑Fi, peer‑to‑peer Wi‑Fi) để trao đổi dữ liệu giữa iOS devices mà **không cần Internet**.
  - **Nearby Interaction (NI)**: dùng **UWB** (iPhone 11+ / Apple Watch hỗ trợ) để **đo khoảng cách & hướng** chính xác; BLE thường chỉ dùng để trao đổi “discovery token” ban đầu.
  - **External Accessory (EA)**: dành cho **Bluetooth Classic**/**iAP2** và phụ kiện **MFi**. Chỉ dùng được nếu phụ kiện có chứng nhận MFi và công bố protocol phù hợp.

**Vì sao phải như vậy?** iOS ưu tiên bảo mật & quyền riêng tư nên *sandboxes* truy cập phần cứng. Do đó, bạn “chạm” Bluetooth qua các API ổn định (GATT, MPC, NI, EA) thay vì điều khiển radio thô.

---

## 2) BLE (CoreBluetooth) — cơ chế “vì sao gọi là GATT”

- **GATT (Generic Attribute Profile)**: “Generic” vì là **khuôn mẫu chung** cho mọi dịch vụ BLE; “Attribute” là **bản ghi khóa–giá trị** nhỏ (ví dụ characteristic value). “Profile” là **bộ quy tắc** tổ chức và truy cập các thuộc tính.
- **Service**: nhóm logic các **Characteristic**.
- **Characteristic**: đơn vị dữ liệu/điều khiển chính có **Properties** (read/write/notify…).
- **Descriptor**: metadata bổ sung cho Characteristic.
- **Vai trò**:
  - **Peripheral**: quảng bá (*advertising*), **expose** GATT database (services/characteristics).
  - **Central**: **scan → connect → discover services/characteristics → read/write/subscribe notify**.
- **Dòng chảy cơ bản khi 2 iPhone nói chuyện qua BLE**:
  1) iPhone A (Peripheral) **startAdvertising** service UUID tùy bạn định nghĩa (128‑bit).
  2) iPhone B (Central) **scanForPeripherals(withServices:)**, tìm A theo service UUID.
  3) Central **connect** → **discoverServices** → **discoverCharacteristics**.
  4) Central **writeValue** lên characteristic (kiểu `.withResponse` hoặc `.withoutResponse`) và/hoặc **setNotifyValue(true)** để nhận callback dữ liệu.

> BLE phù hợp payload nhỏ/trung bình, trao đổi lệnh/thông báo theo sự kiện. Với dữ liệu lớn/stream, hãy cân nhắc **MPC** hoặc thiết kế **chunking** + **retry**.

---

## 3) Multipeer Connectivity — khi cần “đường truyền tự chọn” & payload lớn

- MPC **tự thương lượng** đường truyền cục bộ (Bluetooth, Wi‑Fi LAN, Wi‑Fi P2P) và quản lý **discovery + session + encryption**.
- Khái niệm chính: **MCPeerID** (định danh), **MCSession** (kênh mã hóa, gửi `Data`/stream/file), **Advertiser/Browser** (tìm/ghép cặp peers).
- Dùng MPC để: chat, gửi file, đồng bộ trạng thái nhiều máy, hoặc **trao đổi token** cho Nearby Interaction.

**Vì sao gọi là “Multipeer”?** Vì một thiết bị có thể kết nối **nhiều peer** cùng lúc trong **một hoặc nhiều phiên** (*session*).

---

## 4) Nearby Interaction (UWB) — chính xác khoảng cách/hướng

- NI dùng **UWB** để đo **khoảng cách và góc** giữa các thiết bị/phụ kiện hỗ trợ U1. 
- BLE/MPC thường chỉ đảm nhiệm **trao đổi token** cho bước bắt tay ban đầu, sau đó phép đo chi tiết do UWB cung cấp.
- Dùng NI khi nhu cầu **định vị chính xác**, không phải throughput dữ liệu.

---

## 5) External Accessory (MFi) — Bluetooth Classic/iAP2

- EA cho phép app nói chuyện với **phụ kiện MFi** qua **Bluetooth Classic** hoặc cổng vật lý. 
- **Không dùng** EA cho BLE (BLE dùng CoreBluetooth). EA đòi hỏi phụ kiện phải có **chứng nhận MFi** và **protocol string** được cấp.

**Vì sao phải MFi?** Để đảm bảo **tương thích—bảo mật—chất lượng** cho giao tiếp Classic/iAP2 trên iOS.

---

## 6) Thiết kế giao thức tùy biến

- **Đặt Service/Characteristic UUID** riêng (128‑bit). 
- **Framing**: nên dùng **length‑prefixed** (4 byte độ dài + payload) hoặc **CBOR/Protobuf**.
- **Versioning**: quảng bá version trong advertisement (giới hạn rất nhỏ) hoặc **đọc tay** từ characteristic meta.
- **Độ tin cậy**: chọn `.withResponse` (ACK theo gói) hoặc tự xây ACK/NACK nếu `.withoutResponse`.
- **Bảo mật**: dữ liệu nhạy cảm → mã hóa đầu cuối (**CryptoKit**) hoặc đẩy lên MPC/TLS khi hợp lý.
- **Giới hạn BLE**: MTU/throughput phụ thuộc thiết bị; **chunking** + **retry** + **backoff** là bắt buộc với payload lớn.

---

## 7) Mã mẫu — 2 iPhone nói chuyện qua BLE

> Mục đích minh họa: 1 bên **Peripheral** (quảng bá 1 service + 1 characteristic write/notify), 1 bên **Central** (quét, kết nối, write, subscribe notify).

### 7.1 Khai báo UUID chung

```swift
import CoreBluetooth

let serviceUUID     = CBUUID(string: "12345678-ABCD-4321-ABCD-1234567890AB")
let commandCharUUID = CBUUID(string: "12345678-ABCD-4321-ABCD-1234567890AC")
```

### 7.2 Peripheral: quảng bá & nhận lệnh

```swift
import CoreBluetooth

final class PeripheralMgr: NSObject, CBPeripheralManagerDelegate {
    private var pm: CBPeripheralManager!
    private var commandChar: CBMutableCharacteristic!

    override init() {
        super.init()
        pm = CBPeripheralManager(delegate: self, queue: nil)
    }

    func peripheralManagerDidUpdateState(_ p: CBPeripheralManager) {
        guard p.state == .poweredOn else { return }
        commandChar = CBMutableCharacteristic(
            type: commandCharUUID,
            properties: [.write, .notify],
            value: nil,
            permissions: [.writeable]
        )
        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [commandChar]
        p.add(service)

        p.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
            CBAdvertisementDataLocalNameKey: "Phone-Peripheral"
        ])
    }

    func peripheralManager(_ p: CBPeripheralManager, didWrite requests: [CBATTRequest]) {
        for r in requests {
            if let data = r.value {
                let text = String(decoding: data, as: UTF8.self)
                print("⬅️ Central gửi: \(text)")
                // ví dụ: phản hồi lại qua notify
                let reply = Data("Đã nhận: \(text)".utf8)
                p.updateValue(reply, for: commandChar, onSubscribedCentrals: nil)
            }
            p.respond(to: r, withResult: .success)
        }
    }
}
```

### 7.3 Central: quét, kết nối, write, subscribe

```swift
import CoreBluetooth

final class CentralMgr: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var central: CBCentralManager!
    private var target: CBPeripheral?
    private var commandChar: CBCharacteristic?

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ cm: CBCentralManager) {
        guard cm.state == .poweredOn else { return }
        cm.scanForPeripherals(withServices: [serviceUUID])
    }

    func centralManager(_ cm: CBCentralManager, didDiscover p: CBPeripheral,
                        advertisementData: [String: Any], rssi: NSNumber) {
        central.stopScan()
        target = p
        p.delegate = self
        central.connect(p)
    }

    func centralManager(_ cm: CBCentralManager, didConnect p: CBPeripheral) {
        p.discoverServices([serviceUUID])
    }

    func peripheral(_ p: CBPeripheral, didDiscoverServices error: Error?) {
        guard let s = p.services?.first(where: { $0.uuid == serviceUUID }) else { return }
        p.discoverCharacteristics([commandCharUUID], for: s)
    }

    func peripheral(_ p: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let ch = service.characteristics?.first(where: { $0.uuid == commandCharUUID }) else { return }
        commandChar = ch
        p.setNotifyValue(true, for: ch)
        let data = Data("Hello-BLE".utf8)
        p.writeValue(data, for: ch, type: .withResponse)
    }

    func peripheral(_ p: CBPeripheral, didUpdateValueFor ch: CBCharacteristic, error: Error?) {
        if let v = ch.value {
            print("⬅️ Peripheral phản hồi: \(String(decoding: v, as: UTF8.self))")
        }
    }
}
```

---

## 8) MPC: xương sống cho payload lớn hoặc fallback radio

```swift
import MultipeerConnectivity

final class MPCSession: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    private let peerID = MCPeerID(displayName: UIDevice.current.name)
    private lazy var session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
    private let serviceType = "demo-chat"
    private lazy var advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
    private lazy var browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)

    override init() {
        super.init()
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }

    func advertiser(_ a: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }

    func browser(_ b: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        b.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func session(_ s: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("⬅️ MPC: \(String(decoding: data, as: UTF8.self))")
    }

    // các delegate còn lại để trống cho gọn
    func session(_ s: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {}
    func session(_ s: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ s: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ s: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {}
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}
```

---

## 9) Kiểm thử & vận hành
- Bật **Background Modes** → *Uses Bluetooth LE accessories* nếu cần tương tác nền.
- Thử nghiệm với **hai iPhone thật**. BLE trên Simulator rất hạn chế.
- Với NI (UWB), đảm bảo thiết bị hỗ trợ U1; token discovery có thể trao đổi bằng MPC.
- Ghi log BLE bằng **PacketLogger** (từ *Additional Tools for Xcode*).

---

## 10) Tài liệu tham khảo nhanh (để bạn tra cứu)
1. Apple Developer — **CoreBluetooth** (Overview, CBCentralManager, CBPeripheralManager)  
2. Apple Sample — **Transferring Data Between BLE Devices** (iOS‑to‑iOS, Central/Peripheral mẫu)  
3. Apple Developer — **MultipeerConnectivity** (MCPeerID, MCSession, Advertiser/Browser)  
4. Apple Developer — **Nearby Interaction** (UWB, discovery tokens, tích hợp với MPC)  
5. Apple Developer — **ExternalAccessory** & QA1657 (Bluetooth Classic/iAP2, yêu cầu MFi; BLE dùng CoreBluetooth)  

> Chi tiết link đầy đủ đã được nhúng trong bản gốc của tài liệu này để bạn dễ mở và chỉnh sửa.