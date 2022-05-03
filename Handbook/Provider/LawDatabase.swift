import SQLite
import Foundation

enum DatabaseError: Error {
    case DoesNotExists
}

class LawDatabase: ObservableObject {
    
    static var shared = LawDatabase()
    
    private var db: Connection? = nil
    private let DB_PATH = Bundle.main.path(forResource: "laws", ofType: "db", inDirectory: "Laws")
    
    var queue = DispatchQueue(label: "database", qos: .background)
    
    @Published
    var isLoading = true
    
    init() {
        
    }
    
    func connect() {
        if let path = DB_PATH {
            db = try? Connection(path)
            isLoading = false
        } else {
            print("DB_PATH is nil")
        }
    }
    
    func getCategories(withLaws: Bool = false) -> [TCategory] {
        var ret = [TCategory]()
        do {
            let rows = try db!.prepare(TCategory.table.order(TCategory.order))
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
    
    func getLaws(uuids: [UUID]) -> [TLaw] {
        return self.getLawsBy(predicate: uuids.map { $0.asDBString() }.contains(TLaw.id))
            .sorted {
                let idx1 = uuids.firstIndex(of: $0.id) ?? -1
                let idx2 = uuids.firstIndex(of: $1.id) ?? -1
                return idx1 < idx2
            }
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
            query = query.order(TLaw.name)
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
