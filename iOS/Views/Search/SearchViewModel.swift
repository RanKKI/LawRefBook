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

        private(set) var category: String? = nil

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
                var result = [TLaw]()
                if searchType == .catalogue {
                    result = await self.titleSearch(text: text, laws: laws)
                } else {
                    result = await self.fulltextSearch(text: text, laws: laws)
                }
                uiThread {
                    self.searchResult = result
                    self.isLoading = false
                    completion()
                }
            }
        }
        
        private func titleSearch(text: String, laws: [TLaw]) async -> [TLaw] {
            return laws.filter { law in
                law.name.contains(text) || text.tokenised().allSatisfy { law.name.contains($0) }
            }
        }
        
        
        private let searchOpQueue: OperationQueue = OperationQueue()

        private func fulltextSearch(text: String, laws: [TLaw]) async -> [TLaw] {
            searchOpQueue.cancelAllOperations()
            let locker = NSLock()
            var results = [TLaw]()
            laws.forEach { law in
                self.searchOpQueue.addOperation {
//                    let content = LocalProvider.shared.getLawContent(law.id)
//                    content.load()
//                    if !content.filterText(text: text).isEmpty {
//                        locker.lock()
//                        results.append(law)
//                        locker.unlock()
//                    }
                }
            }
            searchOpQueue.addBarrierBlock {
                
            }
            searchOpQueue.waitUntilAllOperationsAreFinished()
            return results
        }

        func clearSearch() {
            submitted = false
            self.searchResult = []
        }

    }
    
}
