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

    var body: some Scene {
        WindowGroup {
            NavigationView {
                LoadingView(isLoading: $db.isLoading, message: "加载中...") {
                    ContentView()
                }
            }
            .task {
                await db.connect()
            }
            .environment(\.managedObjectContext, moc)
            .phoneOnlyStackNavigationView()
            .task {
                IAPManager.shared.loadProducts()
            }
        }
    }

}
