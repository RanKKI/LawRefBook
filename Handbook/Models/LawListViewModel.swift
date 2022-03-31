import SwiftUI

extension LawList {
    
    class ViewModel: ObservableObject {
        
        @Published
        private(set) var categories: [LawCategory] = [LawCategory]()
        
        @Published
        private(set) var searchResults: [Law] = [Law]()
        
        @Published
        private(set) var isLoading = false
        
        private var queue: DispatchQueue
        private var searchQueueItem: DispatchWorkItem?
        
        init() {
            categories = LocalProvider.shared.getLawList()
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
                print("on result")
                DispatchQueue.main.async {
                    self.searchResults = arr
                    self.isLoading = false
                }
            }
            
            self.searchResults = []
            isLoading = true
            if let item = self.searchQueueItem {
                queue.async(execute: item)
            }
        }
    }
    
}
