import SQLite
import Foundation


let dateFormatter:DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()


struct TLaw: Identifiable {
    static let table = Table("law")
    
    static let id = Expression<String>("id")
    static let name = Expression<String>("name")
    static let categoryID = Expression<Int>("category_id")
    static let expired = Expression<Bool>("expired")
    static let level = Expression<String>("level")
    
    static let filename = Expression<String?>("filename")
    static let publish = Expression<String?>("publish")
    
    let id: UUID
    let name: String
    let category: TCategory
    let expired: Bool
    let level: String
    
    let filename: String?
    let publish: Date?
    
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
            publish: pub_at
        )
    }
    
    func filepath() -> String? {
        var filename = self.name
        if let name = self.filename {
            filename = name
        } else if let pub_at = self.publish {
            filename = String(format: "%@($@)", self.name, dateFormatter.string(from: pub_at))
        }
        return Bundle.main.path(forResource: filename, ofType: "md", inDirectory: self.category.folder)
    }
}

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
    
    static let group = Expression<String?>("group")
    
    let id: Int
    let name: String
    let folder: String
    let isSubFolder: Bool
    let group: String?
    let laws: [TLaw]
    
    static func create(level: String, laws: [TLaw]) -> TCategory {
        return TCategory(
            id: -1,
            name: level,
            folder: "",
            isSubFolder: false,
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
            group: row[group],
            laws: laws
        )
    }
}

enum DatabaseError: Error {
    case DoesNotExists
}

class LawDatabase {
    
    static var shared = LawDatabase()
    
    private var db: Connection? = nil
    private let DB_PATH = Bundle.main.path(forResource: "laws", ofType: "db", inDirectory: "Laws")
    
    var queue = DispatchQueue(label: "database", qos: .background)
    
    init() {
        
    }
    
    func connect() {
        if let path = DB_PATH {
            db = try? Connection(path)
        }
    }
    
    func isConnected() -> Bool {
        return db != nil
    }
    
    func getCategories(withLaws: Bool = false) -> [TCategory] {
        var ret = [TCategory]()
        do {
            let rows = try db!.prepare(TCategory.table)
            for row in rows {
                let cateID = row[TCategory.id]
                if withLaws {
                    ret.append(TCategory.create(row: row, laws: self.getLaws(categoryID: cateID)))
                } else {
                    ret.append(TCategory.create(row: row, laws: []))
                }
            }
        } catch {
            
        }
        return ret
    }
    
    func getCategory(id: Int, withLaws: Bool = false) throws -> TCategory {
        try self.getCategory(predicate: TCategory.id == id, withLaws: withLaws)
    }
    
    func getCategory(name: String, withLaws: Bool = false) throws -> TCategory {
        try self.getCategory(predicate: TCategory.name == name, withLaws: withLaws)
    }
    
    private func getCategory(predicate: Expression<Bool>, withLaws: Bool = false) throws -> TCategory {
        do {
            if let row = try db!.pluck(TCategory.table.filter(predicate)) {
                var laws = [TLaw]()
                let cateID = row[TCategory.id]
                if withLaws {
                    laws = self.getLaws(categoryID: cateID)
                }
                return TCategory.create(row: row, laws:laws)
            }
        } catch {
            
        }
        throw DatabaseError.DoesNotExists
    }
    
    func getLaws() -> [TLaw] {
        return self.getLawsBy(predicate: nil)
    }
    
    func getLaws(level: String) -> [TLaw] {
        return self.getLawsBy(predicate: TLaw.level == level)
    }
    
    func getLaws(category: String) -> [TLaw] {
        do {
            let category = try self.getCategory(name: category)
            return self.getLaws(categoryID: category.id)
        } catch {
            print("\(category) not exists in database")
        }
        return []
    }
    
    func getLaws(categoryID: Int) -> [TLaw] {
        return self.getLawsBy(predicate: TLaw.categoryID == categoryID)
    }
    
    func getLaw(uuid: UUID) -> TLaw? {
        return self.getLawsBy(predicate: TLaw.id == uuid.asDBString()).first
    }
    
    private func getLawsBy(predicate: Expression<Bool>?) -> [TLaw] {
        do {
            var query = TLaw.table
            if let predicate = predicate {
                query = query.filter(predicate)
            }
            print("query: \(query)")
            let rows = try db!.prepare(query)
            var categories = [Int: TCategory]()
            var ret = [TLaw]()
            for row in rows {
                let cateID = row[TLaw.categoryID]
                if categories[cateID] == nil {
                    categories[cateID] = try! self.getCategory(id: cateID)
                }
                let law = TLaw.create(row: row, category: categories[cateID]!)
                ret.append(law)
            }
            
            return ret
            
        } catch {
            print("\(error.localizedDescription)")
        }
        return []
    }

    func getLawFilePath(uuid: UUID) -> String? {
        if let law = self.getLaw(uuid: uuid) {
            return law.filepath()
        }
        return nil
        
    }
}
