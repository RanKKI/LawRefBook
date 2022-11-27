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

    func read(law: TLaw) async -> LawContent? {
        guard let db = manager.getDatabaseByLaw(law: law) else {
            return nil
        }
        guard let url = db.getLawLocalFilePath(law: law) else {
            return nil
        }
        guard let data = local.readLocalFile(url: url) else {
            return nil
        }
        return parser.parse(data: data)
    }

}
