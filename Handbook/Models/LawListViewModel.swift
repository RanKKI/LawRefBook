import SwiftUI

extension LawList {
    
    class ViewModel: ObservableObject, Identifiable {
        
        var id = UUID()
        
        @Published
        fileprivate(set) var categories: [LawCategory] = []

        @Published
        fileprivate(set) var folders: [[LawCategory]] = []

        @Published
        fileprivate(set) var searchResults: [Law] = [Law]()

        @Published
        fileprivate(set) var isLoading = false

        fileprivate var queue: DispatchQueue = DispatchQueue(label: "viewmodal", qos: .background)
        fileprivate var searchOpQueue: OperationQueue = OperationQueue()
        fileprivate var listWorkItem: DispatchWorkItem?
        fileprivate var cateogry: String?
        
        fileprivate var searchText: String = ""
        fileprivate var groupMethod: LawGroupingMethod? = nil

        init() {

        }
        
        init(category: String) {
            self.cateogry = category
        }

        fileprivate func searchTextInLaws(text: String, type: SearchType, arr: [Law]) {
            self.searchText = text
            searchOpQueue.cancelAllOperations()
            let start = Date.currentTimestamp()

            if text.isEmpty {
                self.searchResults = []
                self.isLoading = false
                return
            }
            
            let texts = text.tokenised()
            let locker = NSLock()
            isLoading = true
            queue.async { [weak self] in
                var results = [Law]()
                for law in arr {
                    self?.searchOpQueue.addOperation {
                        var add = law.name.contains(text) || texts.allSatisfy { law.name.contains($0) }
                        if type == .fullText && !add {
                            let content = LawProvider.shared.getLawContent(law.id)
                            content.load()
                            add = content.containsText(text: text) || texts.allSatisfy { content.containsText(text: $0) }
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
                    if self?.searchText != text {
                        return
                    }
                    self?.searchResults = results
                    self?.isLoading = false
                    print("time cost \(Date.currentTimestamp() - start)")
                }
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
        
        fileprivate func doRefresh(method: LawGroupingMethod) {
            self.isLoading = true
            queue.async {
                let arr = self.refreshLaws(method: method)
                let cateogires = arr.filter { $0.isSubFolder == nil || $0.isSubFolder == false }
                let folders = Dictionary(grouping: arr.filter { $0.isSubFolder ?? false }, by: \.group)
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
        
        override func doRefresh(method: LawGroupingMethod) {
            self.isLoading = true
            queue.async {
                let arr = self.refreshLaws(method: method)
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.categories = arr
                }
            }
        }

    }
    
}
