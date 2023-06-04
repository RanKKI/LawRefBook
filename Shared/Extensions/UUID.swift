//
//  UUID.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation

extension UUID {

    /* 将 08f1c0c5de2048c38eb96667f1adad12 转换成 UUID */
    static func create(str: String) -> UUID {
        var arr = [""]
        let size = [8, 4, 4, 4, 12]
        for char in str {
            if arr.last!.count == size[arr.count - 1] {
                arr.append("")
            }
            arr[arr.count - 1] = arr[arr.count - 1] + String(char)
        }
        return UUID(uuidString: arr.joined(separator: "-"))!
    }

    func asDBString() -> String {
        return self.uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    }

}


extension UUID: RawRepresentable{
    public init?(rawValue: String) {
        print("recover uuid \(rawValue)")
        self = UUID.create(str: rawValue)
    }

    public var rawValue: String {
        print("save uuid \(asDBString())")
        return asDBString()
    }
}
