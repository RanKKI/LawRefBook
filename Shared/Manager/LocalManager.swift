//
//  LocalManager.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation
import Zip

//enum LocalConst: String {
//
//    case DB_NAME = "db.sqlite3"
//    case DEFAULT_LAW_NAME = "laws"
//
//    enum Ext: String {
//        case META = "meta"
//        case DELETE_FLAG = "delete"
//    }
//
//}

private let EXT_DELETE = "delete"
private let DB_FILE = "db.sqlite3"

// 维护本地文件
final class LocalManager {

    static let shared = LocalManager()
    
    private let package = PackageManager.shared
    private let meta = MetadataManager.shared

    private var basePath: URL? { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first }

    var lawsFolder: URL? { basePath?.appendingPathComponent("laws", conformingTo: .directory) }
    var cacheFolder: URL? { basePath?.appendingPathComponent("cache", conformingTo: .directory) }

    lazy var ANIT996_LICENSE: String? = {
        InBundle.readFile(path: Bundle.main.path(forResource: "LICENSE", ofType: nil))
    }()
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()


    func isLawPendingDelete(name lawName: String) -> Bool {
        guard let lawPath = lawsFolder?.appendingPathComponent(lawName) else { return false }
        let hashFile = lawPath.appendingPathExtension(EXT_DELETE)
        return hashFile.isExists()
    }

    /*
     解压 zip 文件到 cache/{name}
     解压完成后会移动到 laws/{name}

     如果目标目录有内容，强制删除
     最后写入 hash 到 laws/{name}.hash
     */
    func unzipLaw(at zipPath: URL?, name: String, hash: String, updateAt: Int = -1, deleteZip: Bool = false) throws {
        let meta = PackageMetadata(name: name, hash: hash, update: updateAt)
        try self.unzipLaw(at: zipPath, meta: meta, deleteZip: deleteZip)
    }

    func unzipLaw(at zipPath: URL?, meta: IPackageMetadata, deleteZip: Bool = false) throws {
        guard let zipPath = zipPath else { return }
        guard let targetPath = lawsFolder?.appendingPathComponent(meta.name) else { return }
        guard let cachePath = cacheFolder?.appendingPathComponent(meta.name) else { return }

        try? targetPath.remove()
        try? cachePath.remove()

        try Zip.unzipFile(zipPath, destination: cachePath, overwrite: true, password: nil)
        try FileManager.default.moveItem(at: cachePath, to: targetPath)

        if deleteZip {
            try? zipPath.remove()
        }

        _ = self.meta.save(meta: meta)
    }
    
    /*
     delete 某个 DLC 时候，不能立马删除
     而是写入一个标记位，下次启动的时候删
     */
    func deleteLaw(name: String, revert: Bool = false) {
        guard let targetPath = lawsFolder?.appendingPathComponent(name) else { return }
        let flagPath = targetPath.appendingPathExtension(EXT_DELETE)
        if !revert && !flagPath.isExists(){
            try? String("").data(using: .utf8)?.write(to: flagPath)
        } else if revert {
            try? flagPath.remove()
        }
    }

    private func removeDeletedLaws() {
        guard let baseFolder = lawsFolder else { return }
        guard let files = try? baseFolder.files() else { return }

        files.filter { $0.pathExtension == EXT_DELETE }
            .map { $0.deletingPathExtension() }
            .map { [$0,
                    $0.appendingPathExtension(MetadataManager.Ext),
                    $0.appendingPathExtension(EXT_DELETE)
                ] }
            .reduce([], { return $0 + $1 })
            .forEach {
                try? $0.remove()
            }
    }

    func createFolders() {
        [cacheFolder, lawsFolder]
            .filter { $0 != nil }
            .map { $0! }
            .filter { !$0.isExists() }
            .forEach { try? $0.createDirectory() }
    }

    // 获取本地所有数据库位置
    func getDatabaseFiles() -> [URL] {
#if DEBUG
        print("local path \(String(describing: basePath))")
#endif
        guard let lawsFolder = lawsFolder else { return [] }
        if !lawsFolder.isExists() || package.needUpdate() {
            print("Update required")
            try! self.unzipLaw(at: package.builtInLawPath, meta: package.buildInLawMeta)
        }
        self.removeDeletedLaws()
        do {
            let ret = try lawsFolder.subDirectories()
                .filter { !$0.appendingPathExtension(EXT_DELETE).isExists()  }
                .map { $0.appendingPathComponent(DB_FILE) }
print(ret)
            return ret
        } catch {
            fatalError("\(error)")
        }
    }

    private func removeFile(url: URL) throws {
        if !url.isExists() {
            return
        }
        if url.isDirectory {
            let files = try FileManager.default.contentsOfDirectory(atPath: url.path)
            for file in files {
                try removeFile(url: url.appendingPathComponent(file))
            }
        }
        try FileManager.default.removeItem(atPath: url.path)
    }

}

extension LocalManager {

    enum InBundle {

        static func readFile(path: String?) -> String? {
            guard let path = path else {
                return nil
            }
            return try? String(contentsOfFile: path)
        }

    }

}
