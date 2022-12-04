//
//  Data.swift
//  RefBook
//
//  Created by Hugh Liu on 1/12/2022.
//

import Foundation

extension Data {

    func asUTF8String() -> String {
        return String(decoding: self, as: UTF8.self)
    }

    func decodeJSON<T>(_ type: T.Type) -> T? where T: Decodable {
        do {
            return try JSONDecoder().decode(type, from: self)
        } catch {
            return nil
        }
    }

}
