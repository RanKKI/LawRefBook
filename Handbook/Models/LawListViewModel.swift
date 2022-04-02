import SwiftUI

extension LawList {
    
    class ViewModel: ObservableObject {
        
        @Published
        fileprivate(set) var categories: [LawCategory] = []

        @Published
        fileprivate(set) var folders: [[LawCategory]] = []

        @Published
        fileprivate(set) var searchResults: [Law] = [Law]()

        @Published
        fileprivate(set) var isLoading = false

        fileprivate var queue: DispatchQueue
        fileprivate var searchQueueItem: DispatchWorkItem?
        fileprivate var listWorkItem: DispatchWorkItem?
        fileprivate var cateogry: String?

        init() {
            searchResults = LocalProvider.shared.getLaws()
            queue = DispatchQueue(label: "viewmodal", qos: .background)
        }
        
        init(category: String) {
            self.cateogry = category
            searchResults = LocalProvider.shared.getLaws()
            queue = DispatchQueue(label: "viewmodal", qos: .background)
        }
        
        fileprivate func searchTextInLaws(text: String, type: SearchType, arr: [Law]) {
            self.searchQueueItem?.cancel()

            if text.isEmpty {
                self.searchResults = []
                self.isLoading = false
                return
            }

            self.searchQueueItem = DispatchWorkItem {
                var restuls = [Law]()
                if type == .catalogue {
                    restuls = arr.filter { $0.name.contains(text) }
                } else if type == .fullText {
                    restuls = arr.filter {
                        if $0.name.contains(text) {
                            return true
                        }
                        let content = LawProvider.shared.getLawContent($0.id)
                        content.load()
                        return content.containsText(text: text)
                    }
                }
                DispatchQueue.main.async {
                    self.searchResults = restuls
                    self.isLoading = false
                }
            }

            if let item = self.searchQueueItem {
                isLoading = true
                queue.async(execute: item)
            }
        }

        func searchText(text: String, type: SearchType) {
            searchTextInLaws(text: text, type: type, arr: LocalProvider.shared.getLaws())
        }
        
        fileprivate func refreshLaws(method: LawGroupingMethod) -> [LawCategory]{
            var arr: [LawCategory] = []
            if method == .department {
                arr = LocalProvider.shared.getLawList()
            } else if method == .level {
                arr = Dictionary(grouping: LocalProvider.shared.getLaws(), by: \.level)
                    .sorted {
                        return LawLevel.firstIndex(of: $0.key)! < LawLevel.firstIndex(of: $1.key)!
                    }
                    .map {
                        LawCategory($0.key, $0.value)
                    }
            }
            return arr
        }

        func onGroupingChange(method: LawGroupingMethod) {
            let arr = refreshLaws(method: method)
            self.categories = arr.filter { $0.isSubFolder == nil || $0.isSubFolder == false }
            self.folders = Dictionary(grouping: arr.filter { $0.isSubFolder ?? false }, by: \.group)
                .sorted {
                    if $0.key == nil {
                        return false
                    } else if $1.key == nil {
                        return true
                    } else {
                        return $0.key! < $1.key!
                    }
                }
                .map {
                    $0.value
                }
        }
    }
    
    class SpecificCategoryViewModal: ViewModel {
        
        override init(category: String) {
            super.init(category: category)
            searchResults = searchResults.filter {$0.cateogry?.category == category }
        }

        override func searchText(text: String, type: SearchType) {
            guard self.cateogry != nil else {
                return
            }
            self.searchTextInLaws(text: text, type: type, arr: self.categories.flatMap { $0.laws })
        }

        fileprivate override func refreshLaws(method: LawGroupingMethod) -> [LawCategory]{
            guard self.cateogry != nil else {
                return []
            }
            let arr: [LawCategory] = super.refreshLaws(method: method)
            return arr.filter { $0.category == self.cateogry}
        }
        
        override func onGroupingChange(method: LawGroupingMethod) {
            self.categories = refreshLaws(method: method)
        }

    }
    
}
