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
        var searchResult = [TLaw]()
        
        private(set) var category: String? = nil
        
        init() {
            print("init \(self)")
        }
        
        init(category: String?) {
            self.category = category
            print("init \(Unmanaged.passUnretained(self).toOpaque())")
        }

        func search(text: String, completion: @escaping () -> Void) {
            print("search \(text)")
            uiThread {
                self.isLoading = true
            }
            DispatchQueue.main.async(qos: .background) {
                var laws = [TLaw]()
                if let category = self.category {
                    laws = LawDatabase.shared.getLaws(category: category)
                } else {
                    laws = LawDatabase.shared.getLaws()
                }
                print("laws \(laws.count)")
                laws = laws.filter { $0.name.contains(text) }
                print("laws \(laws.count)")
                uiThread {
                    self.searchResult = laws
                    self.isLoading = false
                    print("search \(Unmanaged.passUnretained(self).toOpaque())")
                    completion()
                }
            }
        }
        
        func clearSearch() {
            self.searchResult = []
        }

    }
    
}
