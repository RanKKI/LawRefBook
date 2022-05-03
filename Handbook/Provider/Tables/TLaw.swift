import SQLite
import Foundation

struct TLaw: Identifiable {
    static let table = Table("law")
    
    static let id = Expression<String>("id")
    static let name = Expression<String>("name")
    static let categoryID = Expression<Int>("category_id")
    static let expired = Expression<Bool>("expired")
    static let level = Expression<String>("level")
    
    static let filename = Expression<String?>("filename")
    static let publish = Expression<String?>("publish")
    static let order = Expression<Int?>("order")
    
    let id: UUID
    let name: String
    let category: TCategory
    let expired: Bool
    let level: String
    
    let filename: String?
    let publish: Date?
    let order: Int?
    
    static func create(row: Row, category: TCategory) -> TLaw {
        
        var pub_at: Date? = nil
        if let pub = row[publish] {
            pub_at = dateFormatter.date(from: pub)
        }
        
        return TLaw(
            id: UUID.create(str: row[id]),
            name: row[name],
            category: category,
            expired: row[expired],
            level: row[level],
            filename: row[filename],
            publish: pub_at,
            order: row[order]
        )
    }
    
    func filepath() -> String? {
        var filename = self.name
        if let name = self.filename {
            filename = name
        } else if let pub_at = self.publish {
            filename = String(format: "%@(%@)", self.name, dateFormatter.string(from: pub_at))
        }
        let ret = Bundle.main.path(forResource: filename, ofType: "md", inDirectory: String(format: "%@/%@", "Laws", self.category.folder))
        if ret == nil {
            print("file is nil \(self.name) \(filename)")
        }
        return ret
    }
}
