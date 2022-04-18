import Foundation
import CoreData
import SwiftUI

class LawProvider: ObservableObject{

    static let shared = LawProvider()

    var queue: DispatchQueue = DispatchQueue(label: "laws", qos: .background)
    
    @AppStorage("iCloudSyncToggle")
    private var enableCloudSync = false
    
    lazy var container : NSPersistentContainer = {
        
        let container = NSPersistentCloudKitContainer(name: "LawData")
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        let defaultDesctiption = container.persistentStoreDescriptions.first
        let url = defaultDesctiption?.url?.deletingLastPathComponent()

        let localStoreDescription = NSPersistentStoreDescription(url: url!.appendingPathComponent("local.sqlite"))
        localStoreDescription.configuration = "Default"
        localStoreDescription.shouldInferMappingModelAutomatically = true
        localStoreDescription.shouldMigrateStoreAutomatically = true
        
        var descriptions = [
            localStoreDescription
        ]

        if enableCloudSync {
            let cloudStoreDescription = NSPersistentStoreDescription(url: url!.appendingPathComponent("cloud.sqlite"))
            cloudStoreDescription.configuration = "Cloud"
            cloudStoreDescription.shouldInferMappingModelAutomatically = true
            cloudStoreDescription.shouldMigrateStoreAutomatically = true


            // Set the container options on the cloud store
            cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.xyz.rankki.law-handbook")
            
            descriptions.append(cloudStoreDescription)
        }
        
        container.persistentStoreDescriptions = descriptions
        
        // Load both stores
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError("Could not load persistent stores. \(error!)")
            }
        }
        
        return container

    }()

    private var contents: [UUID: LawContent] = [UUID: LawContent]()

    func getLawNameByUUID(_ uuid: UUID) -> String {
        return LocalProvider.shared.getLaw(uuid)?.name ?? ""
    }

    func getLawSubtitleByUUID(_ uuid: UUID) -> String {
        return LocalProvider.shared.getLaw(uuid)?.subtitle ?? ""
    }

    func getLawTitleByUUID(_ uuid: UUID) -> String {
        let content = getLawContent(uuid)
        content.load()
        return content.Titles.joined(separator: " ")
    }
    
    private var writeLocker = NSLock()

    func getLawContent(_ uuid: UUID) -> LawContent {
        writeLocker.lock()
        if contents[uuid] == nil {
            if let law = LocalProvider.shared.getLaw(uuid) {
                contents[uuid] = LawContent(law: law)
            } else {
                fatalError("unexpected law uuid: \(uuid)")
            }
        }
        writeLocker.unlock()
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
