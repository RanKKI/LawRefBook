import CoreData
import SwiftUI

class Persistence {

    static var shared = Persistence()

    private let containerID = "iCloud.xyz.rankki.law-handbook"

    lazy var container : NSPersistentContainer = {
    
        let container = NSPersistentCloudKitContainer(name: "LawData")
        
        let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard baseURL != nil else {
            fatalError("Persistence base URL is nil")
        }
        
        let cloudURL = baseURL!.appendingPathComponent("cloud.sqlite")
        let localURL = baseURL!.appendingPathComponent("local.sqlite")

        let localDesc = NSPersistentStoreDescription(url: localURL)
        localDesc.configuration = "Local"

        let cloudDesc = NSPersistentStoreDescription(url: cloudURL)
        cloudDesc.configuration = "Cloud"
        cloudDesc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        cloudDesc.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerID)
        cloudDesc.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.persistentStoreDescriptions = [cloudDesc, localDesc]
        
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
