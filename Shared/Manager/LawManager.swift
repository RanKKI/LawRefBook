//
//  Laws.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation
import SQLite

class LawDB {
    
    private var connection: Connection
    var categories = [Int: TCategory]()
    
    init(path: String) throws {
        connection = try Connection(path)
    }

    func getCategories() async -> [TCategory] {
        var rows = AnySequence<Row>([])
        do {
            rows = try connection.prepare(TCategory.table.order(TCategory.order))
        } catch {
            print(error.localizedDescription)
            return []
        }
        
        return rows.map { TCategory.create(row: $0, laws: []) }
    }

    func getLaws(predicate: Expression<Bool>? = nil) async -> [TLaw] {
        var rows = AnySequence<Row>([])
        
        var query = TLaw.table
        if let predicate = predicate {
            query = query.filter(predicate)
        }
        query = query.order(TLaw.order.asc, TLaw.name)

        do {
            rows = try connection.prepare(query)
        } catch {
            print(error.localizedDescription)
            return []
        }

        var ret = [TLaw]()
        for row in rows {
            guard let id = try? row.get(TLaw.categoryID) else {
                continue
            }
            guard let category = categories[id] else {
                continue
            }
            ret.append(TLaw.create(row: row, category: category))
        }
        return ret
    }

}

final class LawManager: ObservableObject {
    
    static let shared = LawManager()

    @Published
    var isLoading = false

    private var dbs = [LawDB]()
    
    private var categories = [TCategory]()
    private var categoryMap = [Int: TCategory]()

    func connect() async {
        uiThread {
            self.isLoading = true
        }
        do {
            dbs = try LocalManager.shared.getDatabaseFiles()
                .map {
                    print("db path \($0)")
                    return try LawDB(path: $0.absoluteString)
                }
        } catch {
            fatalError("unable to connect all sqlite file")
        }
        await self.preflight()
        for db in dbs {
            db.categories = categoryMap
        }
        uiThread {
            self.isLoading = false
        }
    }

    // 加载所有 Category
    func preflight() async {
        for db in dbs {
            let tempArr = await db.getCategories()
            self.categories.append(contentsOf: tempArr)
        }
        for category in categories {
            categoryMap[category.id] = category
        }
    }
    
    private func getCategoryID(name: String) -> Int? {
        return self.categories.first { $0.name == name }?.id
    }
    
    // 取所有 TLaws
    private func queryLaws(predicate: Expression<Bool>? = nil) async -> [TLaw] {
        var ret = [TLaw]()
        for db in dbs {
            ret.append(contentsOf: await db.getLaws(predicate: predicate))
        }
        return ret
    }
    
    func getLaw(id: UUID) async -> TLaw? {
        return await queryLaws(predicate: TLaw.id == id.asDBString()).first
    }

    // 根据 Category 获取 Laws
    func getLaws(category: String) async -> [TLaw] {
        guard let cateID = self.getCategoryID(name: category) else {
            return []
        }
        
        return await getLaws(categoryID: cateID)
    }
    
    func getLaws(categoryID: Int) async -> [TLaw] {
        return await queryLaws(predicate: TLaw.categoryID == categoryID)
    }
    
    // 获取所有 Category 和所含的 Laws
    func getCategories(by: LawGroupingMethod) async -> [TCategory] {
        if by == .level {
            return await self.getCategoriesByLevels()
        }
        var ret = [TCategory]()
        for category in categories {
            let laws = await getLaws(categoryID: category.id)
            ret.append(TCategory.create(old: category, laws: laws))
        }
        return ret
    }
    
    private func getCategoriesByLevels() async -> [TCategory] {
        let laws = await self.queryLaws()
        return Dictionary(grouping: laws, by: \.level)
            .sorted {
                return LawLevel.firstIndex(of: $0.key)! < LawLevel.firstIndex(of: $1.key)!
            }
            .enumerated()
            .map {
                return TCategory.create(id: $0, level: $1.key, laws: $1.value)
            }
    }

}
