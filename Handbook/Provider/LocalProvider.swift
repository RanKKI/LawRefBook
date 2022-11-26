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

//    func getLawContent(_ uuid: UUID) async -> LawContent {
//        writeLocker.lock()
//        if contents[uuid] == nil {
//            if let law = await LawManager.shared.getLaw(id: uuid) {
//                contents[uuid] = LawContent(filePath: law.filepath(), isCases: law.level == "案例")
//            } else {
//                fatalError("unexpected law uuid: \(uuid)")
//            }
//        }
//        writeLocker.unlock()
//        return contents[uuid]!
//    }

}
