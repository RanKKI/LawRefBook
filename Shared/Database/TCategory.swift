import SQLite
import Foundation

struct TCategory: Identifiable, Hashable {

    static func == (lhs: TCategory, rhs: TCategory) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }

    static let table = Table("category")

    static let id = SQLExpr<String>("id")
    static let name = SQLExpr<String>("name")
    static let folder = SQLExpr<String>("folder")
    static let isSubFolder = SQLExpr<Bool>("isSubFolder")
    static let order = SQLExpr<Int?>("order")

    static let group = SQLExpr<String?>("group")
    
    let id: UUID
    let name: String
    let folder: String
    let isSubFolder: Bool
    let order: Int?
    let group: String?
    let laws: [TLaw]

    static func create(id: UUID, level: String, laws: [TLaw]) -> TCategory {
        return TCategory(
            id: id,
            name: level,
            folder: "",
            isSubFolder: false,
            order: 0,
            group: nil,
            laws: laws
        )
    }

    static func create(row: Row, laws: [TLaw]) -> TCategory {
        return TCategory(
            id: UUID.create(str: row[id]),
            name: row[name],
            folder: row[folder],
            isSubFolder: row[isSubFolder],
            order: row[order],
            group: row[group],
            laws: laws
        )
    }

    static func create(old: TCategory, laws: [TLaw]) -> TCategory {
        return TCategory(
            id: old.id,
            name: old.name,
            folder: old.folder,
            isSubFolder: old.isSubFolder,
            order: old.order,
            group: old.group,
            laws: laws
        )
    }
}
