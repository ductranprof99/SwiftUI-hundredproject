//
//  ChatDetailViewController.swift
//  hundredproject
//
//  Created by Duc Tran  on 15/9/24.
//

import UIKit

final class ChatDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ChatNetworkManager.instance.delegate = self
        ChatNetworkManager.instance.connect()
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChatDetailViewController: ChatNetworkManagerDelegate {
    func onTyping(message: String) {
    }
        
    func onConnect(message: String) {
    }
    
    func onDisconnect(message: String) {
    }
    
    func onReceiveMessage(message: String) {
    }
}
