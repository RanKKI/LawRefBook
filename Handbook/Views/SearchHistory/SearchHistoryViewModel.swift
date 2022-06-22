import SwiftUI
import CoreData

extension SearchHistoryView {
    
    class VM: ObservableObject {
        
        @Published
        private(set) var histories: [SearchHistory] = []
        
        @AppStorage("defaultSearchHistoryType")
        private var searchHistoryType = SearchHistoryType.share
        
        private(set) var lawID: UUID?
        
        private var moc: NSManagedObjectContext?
        
        var showEmptyAll: Bool {
            !histories.isEmpty
        }

        init(_ lawID: UUID?) {
            self.lawID = lawID
        }
        
        func loadHistories(moc: NSManagedObjectContext) {
            self.moc = moc
            self.histories = (try? moc.fetch(buildRequest(limit: 10))) ?? []
        }
        
        func removeAllHistories() {
            guard moc != nil else {
                return
            }
            let moc = moc!
            let req = buildRequest(limit: nil)
            let arr = (try? moc.fetch(req)) ?? []
            for item in arr {
                moc.delete(item)
            }
            try? moc.save()
            histories = []
        }
        
        private func buildRequest(limit: Int?) -> NSFetchRequest<SearchHistory> {
            let fetchRequest = SearchHistory.fetchRequest()
            
            if searchHistoryType == .standalone {
                if let lawId = lawID {
                    fetchRequest.predicate = NSPredicate(format: "lawId == %@", lawId.uuidString)
                } else {
                    fetchRequest.predicate = NSPredicate(format: "lawId == nil")
                }
            }

            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "searchT", ascending: false)]
            if let limit = limit {
                fetchRequest.fetchLimit = limit
            }
            return fetchRequest
        }
    }
    
}
