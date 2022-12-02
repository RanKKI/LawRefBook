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

    static let id = Expression<Int>("id")
    static let name = Expression<String>("name")
    static let folder = Expression<String>("folder")
    static let isSubFolder = Expression<Bool>("isSubFolder")
    static let order = Expression<Int>("order")

    static let group = Expression<String?>("group")

    let id: Int
    let name: String
    let folder: String
    let isSubFolder: Bool
    let order: Int
    let group: String?
    let laws: [TLaw]

    static func create(id: Int, level: String, laws: [TLaw]) -> TCategory {
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
            id: row[id],
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
