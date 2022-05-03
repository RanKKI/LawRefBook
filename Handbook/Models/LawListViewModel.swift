import SwiftUI

extension LawList {

    class ViewModel: ObservableObject, Identifiable {

        var id = UUID()

        @Published
        fileprivate(set) var categories: [TCategory] = []

        @Published
        fileprivate(set) var folders: [[TCategory]] = []

        @Published
        fileprivate(set) var searchResults: [TLaw] = [TLaw]()

        @Published
        fileprivate(set) var isLoading = false

        @Published
        var isSearching = false

        @Published
        var isSubmitSearch = false

        fileprivate var queue: DispatchQueue = DispatchQueue(label: "viewmodal", qos: .background)
        fileprivate var searchOpQueue: OperationQueue = OperationQueue()
        fileprivate var listWorkItem: DispatchWorkItem?
        fileprivate var cateogry: String?

        fileprivate var searchText: String = ""
        var searchType = SearchType.catalogue
        fileprivate var groupMethod: LawGroupingMethod? = nil

        init() {

        }

        init(category: String) {
            self.cateogry = category
        }

        fileprivate func searchTextInLaws(text: String, type: SearchType, arr: [TLaw]) {
            self.searchText = text
            self.searchType = type
            searchOpQueue.cancelAllOperations()

            if text.isEmpty {
                self.searchResults = []
                self.isLoading = false
                return
            }

            let locker = NSLock()
            isLoading = true
            queue.async { [weak self] in
                var results = [TLaw]()
                for law in arr {
                    self?.searchOpQueue.addOperation {
                        var add = false
                        if type == .fullText {
                            let content = LocalProvider.shared.getLawContent(law.id)
                            content.load()
                            add = !content.filterText(text: text).isEmpty
                        } else if type == .catalogue {
                            add = law.name.contains(text) || text.tokenised().allSatisfy { law.name.contains($0) }
                        }
                        if add {
                            locker.lock()
                            results.append(law)
                            locker.unlock()
                        }
                    }
                }
                self?.searchOpQueue.waitUntilAllOperationsAreFinished()
                DispatchQueue.main.async {
                    if self?.searchText != text || self?.searchType != type {
                        return
                    }
                    self?.searchResults = results
                    self?.isLoading = false
                }
            }
        }

        func submitSearch(_ text: String) {
            if text.isEmpty {
                return
            }
            isSubmitSearch = true
            searchTextInLaws(text: text, type: searchType, arr: LawDatabase.shared.getLaws())
        }

        func clearSearchState() {
            isSubmitSearch = false
        }

        fileprivate func refreshLaws(method: LawGroupingMethod) -> [TCategory]{
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

        fileprivate func doRefresh(method: LawGroupingMethod) {
            self.isLoading = true
            queue.async {
                let arr = self.refreshLaws(method: method)
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
                DispatchQueue.main.async {
                    self.folders = folders
                    self.categories = cateogires
                    self.isLoading = false
                }
            }
        }

        func refresh(method: LawGroupingMethod) {
            if let groupMethod = self.groupMethod {
                if groupMethod == method {
                    return
                }
            }
            self.groupMethod = method
            self.doRefresh(method: method)
        }
    }

    class SpecificCategoryViewModal: ViewModel {

        override init(category: String) {
            super.init(category: category)
        }

        override func submitSearch(_ text: String) {
            guard self.cateogry != nil else {
                return
            }
            isSubmitSearch = true
            searchTextInLaws(text: text, type: searchType, arr: LawDatabase.shared.getLaws())
            self.searchTextInLaws(text: text, type: searchType, arr: self.categories.flatMap { $0.laws })
        }

        fileprivate override func refreshLaws(method: LawGroupingMethod) -> [TCategory]{
            guard self.cateogry != nil else {
                return []
            }
            let arr: [TCategory] = super.refreshLaws(method: method)
            return arr.filter { $0.name == self.cateogry }
        }

        override func doRefresh(method: LawGroupingMethod) {
            self.isLoading = true
            queue.async {
                let arr = self.refreshLaws(method: method)
                DispatchQueue.main.async {
                    self.categories = arr
                    self.isLoading = false
                }
            }
        }

    }

}
