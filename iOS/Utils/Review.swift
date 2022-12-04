//
//  Review.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation
import UIKit
import StoreKit

enum AppStoreReviewManager {

    static func requestReviewIfAppropriate() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

}
