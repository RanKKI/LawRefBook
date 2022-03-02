
import Foundation

class Law: Codable, Hashable, Equatable {

    var name: String
    var folder: String?
    var filename: String?
    var id: UUID = UUID()
    var category: LawCategory?
    var content: LawContent?

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(folder)
        hasher.combine(filename)
    }

    private enum CodingKeys: String, CodingKey {
        case name, folder, filename
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
    var folder: String?
    var id: UUID = UUID()

    func hash(into hasher: inout Hasher) {
        hasher.combine(category)
        hasher.combine(folder)
    }

    private enum CodingKeys: String, CodingKey {
        case category, laws, folder
    }

}

class LawManager: ObservableObject {

    var rawLaws: [LawCategory] = []
    @Published var laws: [LawCategory] = []

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
                    }
                }
            }
        } catch {
            print("decode error", error)
        }
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
                    filteredLaws.append(LawCategory(category: $0.category, laws: laws))
                }
            }
        }

        self.laws = filteredLaws
    }

}

