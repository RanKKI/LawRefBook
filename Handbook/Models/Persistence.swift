import CoreData
import SwiftUI

struct Persistence {

    static var shared = Persistence()

    @AppStorage("iCloudSyncToggle")
    private var enableCloudSync = false

    lazy var container : NSPersistentContainer = {
        
        let container = NSPersistentCloudKitContainer(name: "LawData")
        
        let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard baseURL != nil else {
            fatalError("Persistence base URL is nil")
        }
        
        let cloudURL = baseURL!.appendingPathComponent("cloud.sqlite")
        let localURL = baseURL!.appendingPathComponent("local.sqlite")
        let containerID = "iCloud.xyz.rankki.law-handbook"
        var descriptions = [NSPersistentStoreDescription]()
        
        let localStoreDescription = NSPersistentStoreDescription(url: localURL)
        localStoreDescription.configuration = "Local"
        
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudURL)
        cloudStoreDescription.configuration = "Cloud"
        descriptions = [cloudStoreDescription, localStoreDescription]

        if enableCloudSync {
            cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerID)
        } else {
            cloudStoreDescription.cloudKitContainerOptions = nil
        }
        
        container.persistentStoreDescriptions = descriptions
        
        // Load both stores
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError("Could not load persistent stores. \(error!)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        do {
              try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
             fatalError("Failed to pin viewContext to the current generation:\(error)")
        }
        
        return container

    }()
    
}
