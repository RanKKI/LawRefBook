import Foundation
import CoreData
import SwiftUI

class LawProvider: ObservableObject{

    static let shared = LawProvider()

    // 持久化储存
    lazy var container: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "LawData")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }

        container.viewContext.shouldDeleteInaccessibleFaults = true
        return container
    }()

    @Published var lawList: [[UUID]] = []

    @AppStorage("defaultGroupingMethod", store: .standard)
    private var groupingMethod = LawGroupingMethod.department

    private func getLawList() -> [[UUID]] {
        let arr = LocalProvider.shared.getLawList()
        if groupingMethod == .level {
            let dict = Dictionary(grouping: arr.flatMap { $0.laws } , by: { $0.level }).sorted {
                return LawLevel.firstIndex(of: $0.key)! < LawLevel.firstIndex(of: $1.key)!
            }
            return dict.map { $0.value.map {$0.id } }
        }
        return arr.map {$0.laws.map {$0.id} }
    }

    func loadLawList() {
        self.lawList = self.getLawList()
    }
    
    @Published
    var isLoading: Bool = false

    func filterLawList(text: String, type: SearchType = .catalogue) {
        DispatchQueue.main.async {
            if type == .catalogue {
                self.filterListByName(text: text)
            } else if type == .fullText {
                self.filterListByContent(text: text)
            }
        }
    }
    
    private func filterListByContent(text: String) {
        let data = self.getLawList()
        if text.isEmpty {
            self.lawList = []
            return
        }
        self.isLoading = true
        var ret: [[UUID]] = []
        data.forEach {
            let arr = $0.filter {
                let content = self.getLawContent($0)
                content.load()
                return content.containsText(text: text)
            }
            if !arr.isEmpty {
                ret.append(arr)
            }
        }
        self.isLoading = false
        self.lawList = ret
    }
    
    private func filterListByName(text: String) {
        let data = self.getLawList()
        if text.isEmpty {
            self.lawList = data
        } else {
            var ret: [[UUID]] = []
            data.forEach {
                let arr = $0.filter {
                    self.getLawNameByUUID($0).contains(text)
                }
                if !arr.isEmpty {
                    ret.append(arr)
                }
            }
            self.lawList = ret
        }
    }

    private var contents: [UUID: LawContent] = [UUID: LawContent]()

    func getLawNameByUUID(_ uuid: UUID) -> String {
        return LocalProvider.shared.lawMap[uuid]?.name ?? ""
    }

    func getLawTitleByUUID(_ uuid: UUID) -> String {
        let content = getLawContent(uuid)
        content.load()
        return content.Titles.joined(separator: " ")
    }

    func getCategoryName(_ uuid: UUID) -> String {
        if groupingMethod == .level {
            return LocalProvider.shared.lawMap[uuid]?.level ?? ""
        }
        return LocalProvider.shared.lawMap[uuid]?.cateogry?.category ?? ""
    }

    func getLawContent(_ uuid: UUID) -> LawContent {
        if contents[uuid] == nil {
            if let law = LocalProvider.shared.getLaw(uuid) {
                let folder: [String?] = ["Laws", law.cateogry?.folder].filter { $0 != nil }
                contents[uuid] = LawContent(law.filename ?? law.name, folder.map{ $0! }.joined(separator: "/"))
            } else {
                fatalError("unexpected law uuid: \(uuid)")
            }
        }
        return contents[uuid]!
    }

    func getLawInfo(_ uuid: UUID) -> [LawInfo]{
        return getLawContent(uuid).Infomations
    }

    func favoriteContent(_ uuid: UUID, line: Int64, folder: FavFolder) {
        let moc = container.viewContext
        moc.perform {
            let fav = FavContent(context: moc)
            fav.id = UUID()
            fav.line = line
            fav.lawId = uuid
            fav.folder = folder
            try? moc.save()
        }
    }

    @AppStorage("favoriteLaws")
    var favoriteUUID: [UUID] = []

    func getFavoriteState(_ uuid: UUID) -> Bool {
        return favoriteUUID.contains(uuid)
    }

    func favoriteLaw(_ uuid: UUID) -> Bool {
        if favoriteUUID.contains(uuid) {
            if let idx = favoriteUUID.firstIndex(of: uuid) {
                favoriteUUID.remove(at: idx)
            }
            return false
        } else {
            favoriteUUID.append(uuid)
            return true
        }
    }
}
