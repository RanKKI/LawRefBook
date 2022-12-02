import SwiftUI
import CoreData

extension SearchHistoryView {

    class VM: ObservableObject {

        @Published
        private(set) var histories: [SearchHistory] = []

        private(set) var lawID: UUID?

        var moc: NSManagedObjectContext?

        var showEmptyAll: Bool {
            get { !histories.isEmpty }
            set { }
        }

        init() {

        }

        init(lawID: UUID?) {
            self.lawID = lawID
        }

        func loadHistories() {
            guard let moc = moc else { return }
            let req = buildRequest(limit: 10)
            let result = try? moc.fetch(req)
            self.histories = result ?? []
        }

        func removeAllHistories() {
            guard let moc = moc else { return }
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

            if Preference.shared.searchHistoryType == .standalone {
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
