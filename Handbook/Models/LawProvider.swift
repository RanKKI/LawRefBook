import Foundation
import CoreData
import SwiftUI

class LawProvider: ObservableObject{

    static let shared = LawProvider()

    var queue: DispatchQueue = DispatchQueue(label: "laws", qos: .background)

    private var contents: [UUID: LawContent] = [UUID: LawContent]()

    func getLawNameByUUID(_ uuid: UUID) -> String {
        return LocalProvider.shared.getLaw(uuid)?.name ?? ""
    }

    func getLawSubtitleByUUID(_ uuid: UUID) -> String {
        return LocalProvider.shared.getLaw(uuid)?.subtitle ?? ""
    }

    func getLawTitleByUUID(_ uuid: UUID) -> String {
        let content = getLawContent(uuid)
        content.load()
        return content.Titles.joined(separator: " ")
    }
    
    private var writeLocker = NSLock()

    func getLawContent(_ uuid: UUID) -> LawContent {
        writeLocker.lock()
        if contents[uuid] == nil {
            if let law = LocalProvider.shared.getLaw(uuid) {
                contents[uuid] = LawContent(law: law)
            } else {
                fatalError("unexpected law uuid: \(uuid)")
            }
        }
        writeLocker.unlock()
        return contents[uuid]!
    }

    func getLawInfo(_ uuid: UUID) -> [LawInfo]{
        return getLawContent(uuid).Infomations
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
