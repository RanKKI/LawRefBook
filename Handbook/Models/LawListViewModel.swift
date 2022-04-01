import SwiftUI

extension LawList {
    
    class ViewModel: ObservableObject {
        
        @Published
        fileprivate(set) var categories: [LawCategory] = []

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

        func searchText(text: String, type: SearchType) {

            self.searchQueueItem?.cancel()
            
            var arr = LocalProvider.shared.getLaws()
            
            if text.isEmpty {
                self.searchResults = arr
                self.isLoading = false
                return
            }

            self.searchQueueItem = DispatchWorkItem {
                if type == .catalogue {
                    arr = arr.filter { $0.name.contains(text) }
                } else if type == .fullText {
                    arr = arr.filter {
                        let content = LawProvider.shared.getLawContent($0.id)
                        content.load()
                        return content.containsText(text: text)
                    }
                }
                DispatchQueue.main.async {
                    self.searchResults = arr
                    self.isLoading = false
                }
            }

            if let item = self.searchQueueItem {
                isLoading = true
                queue.async(execute: item)
            }
        }

        func onGroupingChange(method: LawGroupingMethod) {
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
            self.categories = arr
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
            self.searchQueueItem?.cancel()
            
            var arr = LocalProvider.shared.getLaws()
            
            arr = arr.filter { $0.cateogry?.category == self.cateogry }
            
            if text.isEmpty {
                self.searchResults = arr
                self.isLoading = false
                return
            }

            self.searchQueueItem = DispatchWorkItem {
                if type == .catalogue {
                    arr = arr.filter { $0.name.contains(text) }
                } else if type == .fullText {
                    arr = arr.filter {
                        let content = LawProvider.shared.getLawContent($0.id)
                        content.load()
                        return content.containsText(text: text)
                    }
                }
                DispatchQueue.main.async {
                    self.searchResults = arr
                    self.isLoading = false
                }
            }

            if let item = self.searchQueueItem {
                isLoading = true
                queue.async(execute: item)
            }
        }

        override func onGroupingChange(method: LawGroupingMethod) {
            if let target = self.cateogry {
                if method == .department {
                    if let arr = LocalProvider.shared.getLawList().first(where: { $0.category == target }) {
                        self.categories = [arr]
                    }
                } else if method == .level {
                    self.categories = Dictionary(grouping: LocalProvider.shared.getLaws(), by: \.level)
                        .sorted {
                            return LawLevel.firstIndex(of: $0.key)! < LawLevel.firstIndex(of: $1.key)!
                        }
                        .map {
                            LawCategory($0.key, $0.value)
                        }
                        .filter {
                            $0.category == target
                        }
                }
            }
        }

    }
    
}
