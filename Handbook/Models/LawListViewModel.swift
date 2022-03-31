import SwiftUI

extension LawList {
    
    class ViewModel: ObservableObject {
        
        @Published
        private(set) var categories: [LawCategory] = []

        @Published
        private(set) var searchResults: [Law] = [Law]()
        
        @Published
        private(set) var isLoading = false
        
        private var queue: DispatchQueue
        private var searchQueueItem: DispatchWorkItem?
        private var listWorkItem: DispatchWorkItem?

        init() {
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
            print("onGroupingChange \(arr)")
            self.categories = arr
            
        }
    }
    
}
