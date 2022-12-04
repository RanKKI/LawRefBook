//
//  Array.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

extension Array where Element == FavContent {

    func groupByLaw() -> [[Element]] {
        return Dictionary(grouping: self) { $0.lawId! }
//            .sorted {
//                let id1 = $0.value.first!.lawId!
//                let id2 = $1.value.first!.lawId!
//                let laws: [TLaw] = LawDatabase.shared.getLaws(uuids: [id1, id2])
//                return laws[0].name < laws[1].name
//            }
            .map { $0.value }
            .map { $0.filter { $0.line > 0 }.sorted { $0.line < $1.line } }
    }

}
