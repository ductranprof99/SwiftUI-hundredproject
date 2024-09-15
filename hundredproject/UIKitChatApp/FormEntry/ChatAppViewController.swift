//
//  ChatAppViewController.swift
//  hundredproject
//
//  Created by Duc Tran  on 15/9/24.
//

import UIKit
import SwiftUI

let host = 12

final class ChatAppViewController: UIViewController {
    private var __host = ""
    private var __canConnect = true
    var host: String {
        set {
            __host = newValue
        }
        
        get {
            if __host.isEmpty {
                __host = "http://127.0.0.1:10000"
            }
            return __host
        }
    }

    @IBOutlet weak var checkServerButton: UIButton!
    
    @IBOutlet weak var serverHost: UITextField!
    
    @IBOutlet weak var nameTextInput: UITextField!
    
    @IBOutlet weak var chatRoomInput: UITextField!
    
    @IBAction func handleCheckServer(_ sender: Any) {
        
        if serverHost.text != nil && !serverHost.text!.isEmpty {
            host = serverHost.text ?? ""
        }
        let locHost = host
        ChatNetworkManager.instance.host = host
        ChatNetworkManager.instance.checkHost(onFinish: {
            [weak self, locHost] in
            DispatchQueue.main.async {
                self?.checkServerButton.isEnabled = true
                self?.serverHost.text = locHost
                self?.__canConnect = true
            }
        }, onError: {  [weak self] in
            DispatchQueue.main.async {
                self?.serverHost.text = "error"
            }
        })
    }
    
    @IBAction func handleJoinRoom(_ sender: Any) {
        if !__canConnect {
            // show toas
            return
        }
        if nameTextInput.text == nil || nameTextInput.text!.isEmpty || chatRoomInput.text == nil || chatRoomInput.text!.isEmpty {
            return
        }
    }
    
    @IBAction func handleCreateRoom(_ sender: Any) {
        if !__canConnect {
            // show toas
            return
        }
        if nameTextInput.text == nil || nameTextInput.text!.isEmpty || chatRoomInput.text == nil || chatRoomInput.text!.isEmpty {
            return
        }
        let a = UIKitChatSaveInfo.instance.setInfo(username: nameTextInput.text!, chatRoom: chatRoomInput.text!)
        if a {
            let vc = UIHostingController(rootView: ChatDetailViewHost())
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
