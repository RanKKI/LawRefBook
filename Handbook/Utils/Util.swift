import Foundation
import SwiftUI
import StoreKit
import UIKit
import CoreData

extension View {

    func shareText(_ shareString: String) {
        if let controller = topMostViewController() {
            let activityViewController = UIActivityViewController(activityItems: [shareString], applicationActivities: nil);
            controller.present(activityViewController, animated: true)
        }
    }

}

extension FavContent {

    static func new(moc: NSManagedObjectContext, _ uuid: UUID, line: Int64, folder: FavFolder) {
        let fav = FavContent(context: moc)
        fav.id = UUID()
        fav.line = line
        fav.lawId = uuid
        fav.folder = folder
        try? moc.save()
    }

}
