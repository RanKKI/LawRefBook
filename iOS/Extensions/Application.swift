//
//  Application.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation
import UIKit

extension UIApplication {

    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

}
