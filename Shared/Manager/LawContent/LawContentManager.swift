//
//  LawContentManager.swift
//  RefBook
//
//  Created by Hugh Liu on 27/11/2022.
//

import Foundation

final class LawContentManager {

    static let shared = LawContentManager()

    private let local = LocalManager.shared
    private let manager = LawManager.shared
    private let parser = LawContentParser.shared

    private var cache = [UUID: LawContent]()

    func read(law: TLaw) async -> LawContent? {
        if let content = cache[law.id] {
            return content
        }
        guard let db = manager.getDatabaseByLaw(law: law) else {
            return nil
        }
        guard let url = db.getLawLocalFilePath(law: law) else {
            return nil
        }
        guard let data = url.content else {
            return nil
        }
        let content = parser.parse(data: data)
        cache[law.id] = content
        return content
    }

}
