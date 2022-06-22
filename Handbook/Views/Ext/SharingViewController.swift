import Foundation
import SwiftUI

struct SharingViewController: UIViewControllerRepresentable {
    
    @Binding
    var isPresenting: Bool
    
    var completion: () -> Void
    
    var content: () -> UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresenting {
            uiViewController.present(content(), animated: true, completion: completion)
        }
    }
}
