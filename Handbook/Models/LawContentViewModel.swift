//import Foundation
//import SwiftUI
//import CoreData
//
//extension ALawContentView {
//
//    class LawContentViewModel: ObservableObject {
//
//        @Published
//        fileprivate(set) var isLoading = false
//
//        @Published
//        var scrollPos: Int64? = nil
//
//        @Published
//        fileprivate(set) var hasToc = false
//
//        @Published
//        fileprivate(set) var isFav = false
//
//        @Published
//        fileprivate(set) var isSearchSubmit = false
//
//        @Published
//        fileprivate(set) var titles = [String]()
//
//        @Published
//        fileprivate(set) var body = [TextContent]()
//
//        fileprivate(set) var lawID: UUID
//        
//        @Published
//        fileprivate(set) var content: LawContent
//
//        @Published
//        fileprivate(set) var law: TLaw?
//
//        fileprivate var queue = DispatchQueue(label: "contentVM", qos: .background)
//
//        var searchText: String = ""
//
//        init(_ id: UUID) {
//            lawID = id
//            content = .init()
//        }
//
//        private var isLoaded = false
//        func onAppear() {
//            if isLoaded {
//                return
//            }
//            isLoaded =  true
//            self.loadContent()
//        }
//
//        private func loadContent() {
//            self.isLoading = true
//            queue.async {
//                self.content.load()
//                DispatchQueue.main.async {
//                    withAnimation {
//                        self.titles = self.content.Titles
//                        self.body = self.content.Body
//                        self.hasToc = self.content.hasToc()
//                        self.isLoading = false
//                    }
//                }
//            }
//        }
//
//        func checkFavState(moc: NSManagedObjectContext) {
//            LocalProvider.shared.queue.async {
//                let req = FavLaw.fetchRequest()
//                req.predicate = NSPredicate(format: "id == %@", self.lawID.uuidString)
//                var flag = false
//                if let arr = try? moc.fetch(req), !arr.isEmpty {
//                    flag = true
//                }
//                DispatchQueue.main.async {
//                    self.isFav = flag
//                }
//            }
//        }
//
//        func onFavIconClicked(moc: NSManagedObjectContext) {
//            let flag = isFav
//            LocalProvider.shared.queue.async {
//                if flag {
//                    let req = FavLaw.fetchRequest()
//                    req.predicate = NSPredicate(format: "id == %@", self.lawID.uuidString)
//                    if let arr = try? moc.fetch(req), !arr.isEmpty {
//                        arr.forEach {
//                            moc.delete($0)
//                        }
//                        DispatchQueue.main.async {
//                            try? moc.save()
//                        }
//                    }
//                } else {
//                    let law = FavLaw(context: moc)
//                    law.id = self.lawID
//                    law.favAt = Date.now
//                    DispatchQueue.main.async {
//                        do {
//                            try moc.save()
//                        } catch {
//                            self.isFav = false
//                        }
//                    }
//                }
//            }
//            isFav = !isFav
//        }
//
//        func doSearchText(_ txt: String) {
//            searchText = txt
//            isSearchSubmit = true
//            isLoading = true
//            queue.async {
//                let arr = self.content.filterText(text: txt)
//                DispatchQueue.main.async {
//                    self.body = arr
//                    self.isLoading = false
//                }
//            }
//        }
//
//        func clearSearchState() {
//            searchText = ""
//            isSearchSubmit = false
//            self.body = self.content.Body
//        }
//
//    }
//
//}
