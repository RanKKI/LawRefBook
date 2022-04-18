import CoreData

extension SearchHistory {

    static func add(moc: NSManagedObjectContext, _ text: String) {
        SearchHistory.add(moc: moc, text, nil)
    }

    static func add(moc: NSManagedObjectContext, _ text: String, _ lawID: UUID?) {
        DispatchQueue.main.async(group: .none, qos: .background) {
            let req = SearchHistory.fetchRequest()
            req.predicate = NSPredicate(format: "text == %@", text)

            do {
                let results = try moc.fetch(req)
                if let result = results.first {
                    result.updateSearchT(moc: moc)
                    return
                }
            } catch {
                
            }
            
            let history = SearchHistory(context: moc)
            history.id = UUID()
            history.text = text
            history.lawId = lawID
            history.searchT = Date.currentTimestamp()
            try? moc.save()
        }
    }

    func delete(moc: NSManagedObjectContext) {
        moc.delete(self)
        try? moc.save()
    }
    
    func updateSearchT(moc: NSManagedObjectContext) {
        self.searchT = Date.currentTimestamp()
        try? moc.save()
    }

}
