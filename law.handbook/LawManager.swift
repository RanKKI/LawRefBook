
import Foundation
import CoreData
import SwiftUI

class Law: Codable, Hashable, Equatable, ObservableObject {

    var name: String
    var id: UUID
    var folder: String?
    var filename: String?
    var category: LawCategory?
    var content: LawContent?

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(folder)
        hasher.combine(filename)
    }

    private enum CodingKeys: String, CodingKey {
        case name, folder, filename, id
    }

    static func == (lhs: Law, rhs: Law) -> Bool {
        return lhs.name == rhs.name && lhs.folder == rhs.folder && lhs.filename == rhs.filename
    }

    func getContent() -> LawContent {
        if self.content == nil {
            let filename = self.filename ?? self.name
            let folder: [String?] = ["法律法规", self.category?.folder, self.folder].filter { $0 != nil }
            self.content = LawContent(filename, folder.map{ $0! }.joined(separator: "/"))
        }
        return self.content!
    }

}

struct LawCategory: Codable, Hashable {

    var category: String
    var laws: [Law]
    var id: UUID
    var folder: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(category)
        hasher.combine(folder)
    }

    private enum CodingKeys: String, CodingKey {
        case category, laws, folder, id
    }

}

class LawManager: ObservableObject {

    private var rawLaws: [LawCategory] = []
    private var lawMap = [UUID: Law]()

    @Published var laws: [LawCategory] = []

    @Environment(\.managedObjectContext) var moc

    init() {
        DispatchQueue.main.async {
            self.readLocalConfig()
        }
    }

    func readLocalConfig(){
        do {
            if let jsonData = readLocalFile(forName: "law") {
                self.rawLaws = try JSONDecoder().decode([LawCategory].self, from: jsonData)
                self.laws = self.rawLaws
                self.rawLaws.forEach { category in
                    category.laws.forEach {
                        $0.category = category
                        lawMap[$0.id] = $0
                    }
                }
            }
        } catch {
            print("decode error", error)
        }
    }

    func loadFavState() {
        try? moc.fetch(FavLaw.fetchRequest()).forEach {
            print("law fav", $0)
        }
    }

    func getLawByUUID(uuid: UUID) -> Law? {
        return self.lawMap[uuid]
    }

    func filterLaws(filterString str: String){
        if str.isEmpty {
            self.laws  = self.rawLaws
            return
        }

        var filteredLaws: [LawCategory] = []

        self.rawLaws.forEach {
            if $0.category.contains(str) {
                filteredLaws.append($0)
            } else {
                let laws = $0.laws.filter { $0.name.contains(str) }
                if !laws.isEmpty {
                    filteredLaws.append(LawCategory(category: $0.category, laws: laws, id: $0.id))
                }
            }
        }

        self.laws = filteredLaws
    }

}

