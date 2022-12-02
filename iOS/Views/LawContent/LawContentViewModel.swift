//
//  LawContentViewModel.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation
import CoreData

extension LawContentView {

    class VM: ObservableObject {

        @Published
        var isLoading = true

        @Published
        var searchText: String = ""

        @Published
        var law: TLaw

        @Published
        var content: LawContent?
        
        @Published
        var isFlagged = false

        init(law: TLaw, searchText: String) {
            self.law = law
            self.searchText = searchText
        }

        func onAppear(moc: NSManagedObjectContext) {
            guard content == nil else {
                return
            }
            Task {
                let content = await LawContentManager.shared.read(law: law)
                let flag = await getFlagState(moc: moc)
                uiThread {
                    self.isFlagged = flag
                    self.content = content
                    self.isLoading = false
                }
            }
        }

        func flag(_ moc: NSManagedObjectContext) {
            guard content != nil else { return }
            guard !self.isLoading else { return }
            
            if self.isFlagged {
                let request = FavLaw.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", law.id.uuidString)
                let result = try? moc.fetch(request)
                if let item = result?.first {
                    moc.delete(item)
                }
            } else {
                let item = FavLaw(context: moc)
                item.id = law.id
                item.favAt = Date.now
            }
            do {
                try moc.save()
                isFlagged.toggle()
            } catch {
                
            }
        }
        
        private func getFlagState(moc: NSManagedObjectContext) async -> Bool {
            let request = FavLaw.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", law.id.uuidString)
            let result = try? moc.fetch(request)
            return result?.first != nil
        }

    }

}
