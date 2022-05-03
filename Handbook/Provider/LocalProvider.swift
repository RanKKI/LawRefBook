import Foundation
import CoreData
import SwiftUI

class LocalProvider: ObservableObject{

    static let shared = LocalProvider()

    lazy var ANIT996_LICENSE: String = {
        readLocalFile(forName: "LICENSE", type: "")?.asUTF8String() ?? ""
    }()

    var queue: DispatchQueue = DispatchQueue(label: "laws", qos: .background)

    private var contents: [UUID: LawContent] = [UUID: LawContent]()

    private var writeLocker = NSLock()

    func getLawContent(_ uuid: UUID) -> LawContent {
        writeLocker.lock()
        if contents[uuid] == nil {
            if let law = LawDatabase.shared.getLaw(uuid: uuid) {
                contents[uuid] = LawContent(filePath: law.filepath(), isCases: law.level == "案例")
            } else {
                fatalError("unexpected law uuid: \(uuid)")
            }
        }
        writeLocker.unlock()
        return contents[uuid]!
    }

    @AppStorage("favoriteLaws")
    var favoriteUUID: [UUID] = []

    func getFavoriteState(_ uuid: UUID) -> Bool {
        return favoriteUUID.contains(uuid)
    }

    private var vms = [UUID: LawContentView.LawContentViewModel]()
    func getViewModal(_ uuid: UUID) -> LawContentView.LawContentViewModel {
        if vms[uuid] == nil {
            vms[uuid] = LawContentView.LawContentViewModel(uuid)
        }
        return vms[uuid]!
    }
}
