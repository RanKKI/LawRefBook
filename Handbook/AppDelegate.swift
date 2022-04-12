
import CoreSpotlight
import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
l
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        self.checkJumpInBySpotlight(userActivity)
        return true
    }
    
    private func checkJumpInBySpotlight( _ userActivity: NSUserActivity) {
        if userActivity.activityType == CSSearchableItemActionType {
                if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                    if let navigationController = window?.rootViewController as? UINavigationController {
                        if let viewController = navigationController.topViewController as? ViewController {
                            viewController.showTutorial(Int(uniqueIdentifier)!)
                        }
                    }
                }
            }
    }

}
