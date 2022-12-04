//
//  SearchManager.swift
//  RefBook
//
//  Created by Hugh Liu on 4/12/2022.
//

import Foundation

class SearchManager: ObservableObject {

    static let shared = SearchManager()

    func search(text: String, laws: [TLaw], type: SearchType) async -> [TLaw] {
        if type == .catalogue {
            return await searchTitle(text: text, laws: laws)
        }
        return await searchContent(text: text, laws: laws)
    }

    func searchTitle(text: String, laws: [TLaw]) async -> [TLaw] {
        return laws.filter { law in
            law.name.contains(text) || text.tokenised().allSatisfy { law.name.contains($0) }
        }
    }

    func searchContent(text: String, laws: [TLaw]) async -> [TLaw] {
        var result = [TLaw]()

        for law in laws {
            if let content = await LawContentManager.shared.read(law: law) {
                if await content.hasText(text: text) {
                    result.append(law)
                }
            }
        }

        return result
    }
}
