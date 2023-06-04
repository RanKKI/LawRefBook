import SwiftUI
import CoreSpotlight
import CoreData
import Combine
import WhatsNewKit

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
                        .environment(
                            \.whatsNew,
                            WhatsNewEnvironment(
                                // Specify in which way the presented WhatsNew Versions are stored.
                                // In default the `UserDefaultsWhatsNewVersionStore` is used.
                                versionStore: UserDefaultsWhatsNewVersionStore(),
                                // Pass a `WhatsNewCollectionProvider` or an array of WhatsNew instances
                                whatsNewCollection: self
                            )
                        )
                }
            }
            .task {
                await db.connect()
            }
            .environment(\.managedObjectContext, moc)
            .phoneOnlyStackNavigationView()
            .task {
                IAPManager.shared.loadProducts()
                if Preference.shared.id.isEmpty {
                    Preference.shared.id = UUID().uuidString
                }
            }
        }
    }

}
// MARK: - App+WhatsNewCollectionProvider

extension MainApp: WhatsNewCollectionProvider {

    /// Declare your WhatsNew instances per version
    var whatsNewCollection: WhatsNewCollection {
        WhatsNew(
            version: "1.5.0",
            title: "看，这些新功能",
            features: [
                .init(image: .init(systemName: "captions.bubble"), title: "AI 法律助手", subtitle: "结合语言模型和 Embbeding 提供更为准确的定制化法律咨询"),
                .init(image: .init(systemName: "square.and.arrow.down.on.square"), title: "法律补充包", subtitle: "可以按需下载法律法规"),
//                .init(image: .init(systemName: "creditcard"), title: "Pro 功能", subtitle: "内购（IAP）收入将为我们的开发者账号、服务器、第三方 API 费用及其他日常运营提供支持"),
            ],
            primaryAction: WhatsNew.PrimaryAction(
                title: "Continue",
                backgroundColor: .accentColor,
                foregroundColor: .white,
                hapticFeedback: .notification(.success),
                onDismiss: {

                }
            )
        )
    }

}
