import Foundation
import SwiftUI

public struct AlertConfig {
    public var title: String
    public var placeholder: String = ""
    public var accept: String = "确认"
    public var cancel: String = "取消"
    public var action: (String?) -> Void
}

extension View {

    func alert(config: AlertConfig) {
        let alert = UIAlertController(title: config.title, message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = config.placeholder
        }
        alert.addAction(UIAlertAction(title: config.accept, style: .default) { _ in
            let textField = alert.textFields![0] as UITextField
            config.action(textField.text)
        })
        alert.addAction(UIAlertAction(title: config.cancel, style: .cancel) { _ in
            config.action(nil)
        })
        showAlert(alert: alert)
    }

    private func showAlert(alert: UIAlertController) {
        if let controller = topMostViewController() {
            controller.present(alert, animated: true)
        }
    }

    private func keyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter {$0.activationState == .foregroundActive}
            .compactMap {$0 as? UIWindowScene}
            .first?.windows.filter {$0.isKeyWindow}.first
    }

    func topMostViewController() -> UIViewController? {
        guard let rootController = keyWindow()?.rootViewController else {
            return nil
        }
        return topMostViewController(for: rootController)
    }

    private func topMostViewController(for controller: UIViewController) -> UIViewController {
        if let presentedController = controller.presentedViewController {
            return topMostViewController(for: presentedController)
        } else if let navigationController = controller as? UINavigationController {
            guard let topController = navigationController.topViewController else {
                return navigationController
            }
            return topMostViewController(for: topController)
        } else if let tabController = controller as? UITabBarController {
            guard let topController = tabController.selectedViewController else {
                return tabController
            }
            return topMostViewController(for: topController)
        }
        return controller
    }

}
