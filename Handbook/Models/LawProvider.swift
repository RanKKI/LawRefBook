import Foundation
import CoreData
import SwiftUI

class LawProvider {
    
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
    
    lazy var lawList: [[UUID]] = {
        let laws = LocalProvider.shared.getLawList()
        return laws.map {$0.laws.map {$0.id} }
    }()
    
    private var contents: [UUID: LawContent] = [UUID: LawContent]()
    
    func getLawNameByUUID(_ uuid: UUID) -> String {
        return LocalProvider.shared.lawMap[uuid]?.name ?? ""
    }
    
    func getCategoryName(_ uuid: UUID) -> String {
        return LocalProvider.shared.lawMap[uuid]?.cateogry?.category ?? ""
    }
    
    func getLawContent(_ uuid: UUID) -> LawContent {
        if contents[uuid] == nil {
            if let law = LocalProvider.shared.getLaw(uuid) {
                let folder: [String?] = ["法律法规", law.cateogry?.folder].filter { $0 != nil }
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
    
    func favoriteContent(_ uuid: UUID, line: String) {
        let moc = container.viewContext
        moc.perform {
            let fav = FavContent(context: moc)
            fav.id = UUID()
            fav.content = line
            fav.lawId = uuid
            try? moc.save()
        }
    }
    
    func getFavoriteState(_ uuid: UUID) -> Bool {
        return false // TODO
    }

    func favoriteLaw(_ uuid: UUID) -> Bool {
        return false // TODO
    }

}
