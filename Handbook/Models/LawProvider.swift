import Foundation
import CoreData
import SwiftUI

class LawProvider: ObservableObject{

    static let shared = LawProvider()
    
    
    var queue: DispatchQueue
    
    init() {
        queue = DispatchQueue(label: "laws", qos: .background)
    }

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

    @Published
    var isLoading: Bool = false

    func loadLawList() {
        isLoading = true
        queue.async {
            let arr = self.getLawList()
            DispatchQueue.main.async {
                self.lawList = arr
                self.isLoading = false
            }
        }
    }

    private var contents: [UUID: LawContent] = [UUID: LawContent]()

    func getLawNameByUUID(_ uuid: UUID) -> String {
        return LocalProvider.shared.getLaw(uuid)?.name ?? ""
    }

    func getLawTitleByUUID(_ uuid: UUID) -> String {
        let content = getLawContent(uuid)
        content.load()
        return content.Titles.joined(separator: " ")
    }

    func getCategoryName(_ uuid: UUID) -> String {
        if groupingMethod == .level {
            return LocalProvider.shared.getLaw(uuid)?.level ?? ""
        }
        return LocalProvider.shared.getLaw(uuid)?.cateogry?.category ?? ""
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
