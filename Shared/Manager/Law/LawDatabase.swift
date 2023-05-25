//
//  LawDatabase.swift
//  RefBook
//
//  Created by Hugh Liu on 27/11/2022.
//

import Foundation
import SQLite
import SQLite3

class LawDatabase {

    private var connection: Connection
    var path: URL
    var categories = [Int: TCategory]()

    init(path: URL) throws {
        self.path = path
        self.connection = try Connection(path.absoluteString)
    }
    
    func disconnect() {
        sqlite3_close(self.connection.handle)
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
            print(error)
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

    func getLawLocalFilePath(law: TLaw) -> URL? {
        let folder = self.path.deletingLastPathComponent()
        for name in law.getNames() {
            let file = folder.appendingPathComponent(name, conformingTo: .fileURL).appendingPathExtension("md")
            if file.isFileURL && file.isExists() {
                return file
            }
        }
        return nil
    }
}
