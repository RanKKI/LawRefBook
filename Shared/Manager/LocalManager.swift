//
//  LocalManager.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation
import Zip

// 维护本地文件
final class LocalManager {

    static let shared = LocalManager()

    static let defaultDatabaseName = "db.sqlite3"

    private var baseFolder: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent("laws", conformingTo: .directory)
    }

    private let builtInZipPath = Bundle.main.url(forResource: "default", withExtension: "zip")

    lazy var ANIT996_LICENSE: String? = {
        InBundle.readFile(path: Bundle.main.path(forResource: "LICENSE", ofType: nil))?.asUTF8String()
    }()

    // 第一次打开 App
    // 创建目录 & 解压内置包体
    private func firstRun() throws {
        guard let path = builtInZipPath else { return }
        guard let root = baseFolder else { return }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let unzipDirectory = try Zip.quickUnzipFile(path)
        let targetDirectory = root.appendingPathComponent(unzipDirectory.lastPathComponent)
        try FileManager.default.moveItem(at: unzipDirectory, to: targetDirectory)
    }

    // 获取本地所有数据库位置
    func getDatabaseFiles() -> [URL] {
        guard let root = baseFolder else { return [] }
        #if DEBUG
        print("local path \(root)")
        #endif
        if !root.isExists() {
            do {
                try self.firstRun()
            } catch {
                fatalError("\(error)")
            }
        }
        do {
            return try root.subDirectories()
                .map { $0.appendingPathComponent(LocalManager.defaultDatabaseName)}
        } catch {
            fatalError("\(error)")
        }
    }

    // 删除本地所有数据
    func removeAllLocalFiles() {
        guard let root = baseFolder else { return }
        try? FileManager.default.removeItem(atPath: root.path)
    }

    func readLocalFile(url: URL) -> Data? {
        return FileManager.default.contents(atPath: url.path)
    }

}

extension LocalManager {

    enum InBundle {

        static func readFile(path: String?) -> Data? {
            guard let path = path else {
                return nil
            }
            return try? String(contentsOfFile: path).data(using: .utf8)
        }

    }

}
