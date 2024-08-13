//
//  FirebaseLog.swift
//  hundredproject
//
//  Created by Duc Tran  on 11/8/24.
//

import FirebaseAnalytics

final class FirebaseEventLogging {
    public  static let shared: FirebaseEventLogging = .init()
    
    func logging(_ eventName: String, parameters: [String: Any]) {
        Analytics.logEvent(eventName, parameters: parameters)
    }
}
