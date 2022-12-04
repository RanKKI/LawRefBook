//
//  Date.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation

extension Date {
    static func currentTimestamp() -> Int64 {
        return Int64(Date().timeIntervalSince1970)
    }
}
