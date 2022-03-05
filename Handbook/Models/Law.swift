import Foundation

class Law: Codable {
    var name: String
    var id: UUID
    var filename: String?

    var cateogry: LawCategory?
}

class LawCategory: Codable {
    var category: String
    var laws: [Law]
    var id: UUID
    var folder: String?
}

struct TextContent : Identifiable {
    var id: UUID = UUID()
    var text: String
    var children: [String]
}

struct LawInfo {
    var id: UUID = UUID()
    var header: String
    var content: String
}

extension FavLaw {
    var key: UUID {
        return self.id!
    }
}
