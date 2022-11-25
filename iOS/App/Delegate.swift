//
//  Delegate.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        application.registerForRemoteNotifications()
        return true
    }

}
