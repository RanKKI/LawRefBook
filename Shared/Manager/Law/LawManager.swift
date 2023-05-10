//
//  Laws.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation
import SQLite

final class LawManager: ObservableObject {

    static let shared = LawManager()

    @Published
    var isLoading = true

    private var dbs = [LawDatabase]()

    private var categories = [TCategory]()
    private var categoryMap = [Int: TCategory]()
    private var lawMap = [UUID: LawDatabase]()

    func connect() async {
        do {
            dbs = try LocalManager.shared.getDatabaseFiles()
                .map { try LawDatabase(path: $0) }
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
            self.categories.append(contentsOf: await db.getCategories())
        }
        for category in categories {
            categoryMap[category.id] = category
        }
    }

    private func getCategoryID(name: String) -> Int? {
        return self.categories.first { $0.name == name }?.id
    }

    private func linkLaws(laws: [TLaw], db: LawDatabase) {
        for law in laws {
            if lawMap[law.id] != nil {
                continue
            }
            lawMap[law.id] = db
        }
    }

    // 取所有 TLaws
    private func queryLaws(predicate: Expression<Bool>? = nil) async -> [TLaw] {
        var ret = [TLaw]()
        for db in dbs {
            let laws = await db.getLaws(predicate: predicate)
            self.linkLaws(laws: laws, db: db)
            ret.append(contentsOf: laws)
        }
        return ret
    }

    func getLaw(id: UUID) async -> TLaw? {
        return await queryLaws(predicate: TLaw.id == id.asDBString()).first
    }
    
    func getLaws(nameContains: String) async -> [TLaw] {
        return await queryLaws(predicate: TLaw.name.like("%\(nameContains)%"))
    }

    func getLaws() async -> [TLaw] {
        return await queryLaws(predicate: nil)
    }

    func getLaws(ids: [UUID]) async -> [TLaw] {
        return await queryLaws(predicate: ids.map { $0.asDBString() }.contains(TLaw.id))
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
    
    func getCases() async -> [TLaw] {
        return await queryLaws(predicate: TLaw.level == "案例")
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

    func getDatabaseByLaw(law: TLaw) -> LawDatabase? {
        return lawMap[law.id]
    }
}
