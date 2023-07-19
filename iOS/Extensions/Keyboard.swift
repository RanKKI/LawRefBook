//
//  Keyboard.swift
//  RefBook
//
//  Created by Hugh Liu on 19/7/2023.
//

import Foundation
import Combine
import UIKit

class KeyboardResponder: ObservableObject {
    @Published var isKeyboardShown = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        isKeyboardShown = true
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        isKeyboardShown = false
    }
}
