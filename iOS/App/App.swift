import SwiftUI
import CoreSpotlight
import CoreData
import Combine

@main
struct MainApp: App {

    @UIApplicationDelegateAdaptor
    private var appDelegate: AppDelegate

    private(set) var moc = Persistence.shared.container.viewContext
    
    @ObservedObject
    private var db = LawManager.shared
    
    @ObservedObject
    private var db2 = LawDatabase.shared
    
    var isLoading: Binding<Bool> {
        Binding(
            get: { db.isLoading || db2.isLoading },
            set: { val in
                
            }
        )
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                LoadingView(isLoading: isLoading) {
                    ContentView()
                }
            }
            .task {
                db2.connect()
                await db.connect()
            }
            .environment(\.managedObjectContext, moc)
            .phoneOnlyStackNavigationView()
            .task {
//                self.immigrateFavLaws()
//                IAPManager.shared.loadProducts()
            }
        }
    }

    // 兼容代码
    private func immigrateFavLaws() {
        if LocalProvider.shared.favoriteUUID.isEmpty {
           return
        }
        LocalProvider.shared.queue.async {
            LocalProvider.shared.favoriteUUID.enumerated().forEach { (i, val) in
                let req = FavLaw.fetchRequest()
                req.predicate = NSPredicate(format: "id == %@", val.uuidString)
                var flag = false
                if let arr = try? moc.fetch(req), !arr.isEmpty {
                    flag = true
                }
                if !flag {
                    let law = FavLaw(context: moc)
                    law.id = val
                    law.favAt = Date.now
                    do {
                        try moc.save()
                        DispatchQueue.main.async {
                            if let idx = LocalProvider.shared.favoriteUUID.firstIndex(of: val) {
                                LocalProvider.shared.favoriteUUID.remove(at: idx)
                            }
                        }
                    }catch{
                        print("\(val) 保存失败")
                    }
                }
            }
        }
    }

}
