//
//  LawListViewModel.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation

extension LawListContentView {

    final class VM: ObservableObject {

        @Published
        var categories: [TCategory] = []

        @Published
        var folders: [[TCategory]] = []

        @Published
        var isLoading = true

        @Published
        var searchText = ""
        
        var isSignleCategory: Bool {
            category != nil && categories.count <= 1
        }
        
        var laws: [TLaw] {
            self.categories.flatMap { $0.laws } + folders.flatMap { $0.flatMap { $0.laws } }
        }

        private(set) var category: String? = nil

        init() {
            
        }

        init(category: String?) {
            self.category = category
        }
        
        func onAppear() {
            guard categories.isEmpty && folders.isEmpty else { return }
            Task {
                await self.doRefresh(method: .department)
            }
        }

        fileprivate func refreshLaws(method: LawGroupingMethod) async -> [TCategory]{
            let db = LawDatabase.shared
            if method == .department {
                return db.getCategories(withLaws: true)
            }
            return Dictionary(grouping: db.getLaws(), by: \.level)
                .sorted {
                    return LawLevel.firstIndex(of: $0.key)! < LawLevel.firstIndex(of: $1.key)!
                }
                .enumerated()
                .map {
                    return TCategory.create(id: $0, level: $1.key, laws: $1.value)
                }
        }

        fileprivate func doRefresh(method: LawGroupingMethod) async {
            uiThread {
                self.isLoading = true
            }
            var arr = await self.refreshLaws(method: method)
            if let category = self.category {
                arr = arr.filter { $0.name == category }
                uiThread {
                    self.categories = arr
                    self.isLoading = false
                }
                return
            }
            let cateogires = arr.filter { $0.isSubFolder == false }
            let folders = Dictionary(grouping: arr.filter { $0.isSubFolder }, by: \.group)
                .sorted {
                    let k1 = $0.value.first?.order ?? -1
                    let k2 = $1.value.first?.order ?? -1
                    return k1 < k2
                }
                .map {
                    $0.value
                }
            uiThread {
                self.isLoading = false
                self.folders = folders
                self.categories = cateogires
            }
        }

    }
    
}
