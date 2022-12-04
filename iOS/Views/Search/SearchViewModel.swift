//
//  SearchViewModel.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation

extension SearchView {

    final class VM: ObservableObject {

        @Published
        var searchType: SearchType = .catalogue

        @Published
        var isLoading = false

        @Published
        var submitted = false

        @Published
        var searchResult = [TLaw]()

        private(set) var category: String?

        init(category: String?) {
            self.category = category
        }

        func search(text: String, laws: [TLaw], completion: @escaping () -> Void) {
            submitted = true
            if text.isEmpty {
                self.clearSearch()
                return
            }
            Task {
                uiThread {
                    self.isLoading = true
                }
                let result = await SearchManager.shared.search(text: text, laws: laws, type: searchType)
                uiThread {
                    self.searchResult = result
                    self.isLoading = false
                    completion()
                }
            }
        }

        func clearSearch() {
            submitted = false
            self.searchResult = []
        }

    }

}
