import SQLite
import Foundation

struct TLaw: Identifiable {
    static let table = Table("law")

    static let id = Expression<String>("id")
    static let name = Expression<String>("name")
    static let categoryID = Expression<String>("category_id")
    static let expired = Expression<Bool>("expired")
    static let level = Expression<String>("level")

    static let filename = Expression<String?>("filename")
    static let publish = Expression<String?>("publish")
    static let order = Expression<Int?>("order")
    static let subtitle = Expression<String?>("subtitle")
    static let valid_from = Expression<String?>("valid_from")

    static let ver = Expression<Int>("ver")
    static let tags = Expression<String?>("tags")

    let id: UUID
    let name: String
    let category: TCategory
    let expired: Bool
    let level: String

    let filename: String?
    let publish: Date?
    let order: Int?
    let subtitle: String?
    let is_valid: Bool

    let ver: Int
    let tags: String?
    
    var tagArray: [String] {
        (tags?.split(separator: ",").map {s in
            String(s)
        }) ?? [String]()
    }

    static func create(row: Row, category: TCategory) -> TLaw {

        var pub_at: Date?
        if let pub = row[publish] {
            pub_at = dateFormatter.date(from: pub)
        }

        var is_valid = true
        if let valid = row[valid_from] {
            let dt = dateFormatter.date(from: valid)
            let now = Date.now
            is_valid = dt == nil || dt! < now
        }

        return TLaw(
            id: UUID.create(str: row[id]),
            name: row[name],
            category: category,
            expired: row[expired],
            level: row[level],
            filename: row[filename],
            publish: pub_at,
            order: row[order],
            subtitle: row[subtitle],
            is_valid: is_valid,
            ver: row[ver],
            tags: row[tags]
        )
    }

    func getFilename() -> String {
        if let name = self.filename {
            return name
        } else if let pub_at = self.publish {
            return String(format: "%@(%@)", self.name, dateFormatter.string(from: pub_at))
        }
        return self.name
    }

    func getNames() -> [String] {
        let folder = self.category.folder
        var ret = [
            String(format: "%@/%@", folder, getFilename()),
            String(format: "%@/%@", folder, name)
        ].filter { $0 != nil }.map { $0! }

        if let subtitle = subtitle {
            ret.append(String(format: "%@/%@", folder, subtitle))
        }
        return ret
    }

}
