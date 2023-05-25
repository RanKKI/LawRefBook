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

    static let DB_NAME = "db.sqlite3"
    static let EXT_HASH = "hash"
    static let EXT_DELETE = "delete"
    static let DEFAULT_LAW_NAME = "laws"

    private var basePath: URL? { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first }

    var lawsFolder: URL? { basePath?.appendingPathComponent("laws", conformingTo: .directory) }
    var cacheFolder: URL? { basePath?.appendingPathComponent("cache", conformingTo: .directory) }

    private let inAppLawZip = Bundle.main.url(forResource: LocalManager.DEFAULT_LAW_NAME, withExtension: "zip")
    private var inAppLawHash: URL? { inAppLawZip?.appendingPathExtension(LocalManager.EXT_HASH) }
    private var localLawPath: URL? { lawsFolder?.appendingPathComponent(LocalManager.DEFAULT_LAW_NAME) }
    private var localLawHash: URL? { localLawPath?.appendingPathExtension(LocalManager.EXT_HASH) }

    lazy var ANIT996_LICENSE: String? = {
        InBundle.readFile(path: Bundle.main.path(forResource: "LICENSE", ofType: nil))?.asUTF8String()
    }()

    func getLawHash(name lawName: String) -> String? {
        guard let lawPath = lawsFolder?.appendingPathComponent(lawName) else { return nil }
        let hashFile = lawPath.appendingPathExtension(LocalManager.EXT_HASH)
        return hashFile.utf8Content
    }

    func isLawPendingDelete(name lawName: String) -> Bool {
        guard let lawPath = lawsFolder?.appendingPathComponent(lawName) else { return false }
        let hashFile = lawPath.appendingPathExtension(LocalManager.EXT_DELETE)
        return hashFile.isExists()
    }


    /*
     解压 zip 文件到 cache/{name}
     解压完成后会移动到 laws/{name}

     如果目标目录有内容，强制删除
     最后写入 hash 到 laws/{name}.hash
     */
    func unzipLaw(at zipPath: URL?, name: String, hash: String, deleteZip: Bool = false) throws {
        guard let zipPath = zipPath else { return }
        guard let targetPath = lawsFolder?.appendingPathComponent(name) else { return }
        guard let cachePath = cacheFolder?.appendingPathComponent(name) else { return }

        if targetPath.isExists() {
            try? targetPath.remove()
        }
        
        if cachePath.isExists() {
            try? cachePath.remove()
        }

        try Zip.unzipFile(zipPath, destination: cachePath, overwrite: true, password: nil)
        try FileManager.default.moveItem(at: cachePath, to: targetPath)

        if deleteZip {
            try? zipPath.remove()
        }

        try? hash.data(using: .utf8)?.write(to: targetPath.appendingPathExtension(LocalManager.EXT_HASH))
    }
    
    /*
     delete 某个 DLC 时候，不能立马删除
     而是写入一个标记位
     下次启动的时候删
     */
    func deleteLaw(name: String, revert: Bool = false) {
        guard name != LocalManager.DEFAULT_LAW_NAME else { return }
        guard let targetPath = lawsFolder?.appendingPathComponent(name) else { return }
        let flagPath = targetPath.appendingPathExtension(LocalManager.EXT_DELETE)
        if revert  {
            if flagPath.isExists() {
                try? flagPath.remove()
            }
        } else {
            try? String("").data(using: .utf8)?.write(to: flagPath)
        }
    }

    private func removeDeletedLaws() {
        guard let baseFolder = lawsFolder else { return }
        guard let files = try? baseFolder.files() else { return }
        var waitToDelete = [URL]()
        for file in files {
            if file.pathExtension == LocalManager.EXT_DELETE {
                let baseURL = file.deletingPathExtension()
                waitToDelete.append(contentsOf: [
                    baseURL,
                    baseURL.appendingPathExtension(LocalManager.EXT_HASH),
                    baseURL.appendingPathExtension(LocalManager.EXT_DELETE),
                ])
            }
        }
        for delete in waitToDelete {
            try? delete.remove()
        }
    }

    private func createFolders() {
        let folders = [cacheFolder, lawsFolder]
        for path in folders {
            if let path = path, !path.isExists() {
                try! FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
            }
        }
    }

    private func checkNeedsUpgrade() -> Bool {
        guard let inAppHash = inAppLawHash?.utf8Content else { return false }
        guard let localHash = localLawHash else { fatalError("invalid local path") }
        return localHash.utf8Content != inAppHash
    }

    private func upgradeLocalLaws() {
        guard let hash = inAppLawHash?.utf8Content else { return }
        do {
            self.createFolders();
            self.deleteLaw(name: LocalManager.DEFAULT_LAW_NAME)
            try self.unzipLaw(at: inAppLawZip, name: LocalManager.DEFAULT_LAW_NAME, hash: hash)
        } catch {
            fatalError("\(error)")
        }
    }

    // 获取本地所有数据库位置
    func getDatabaseFiles() -> [URL] {
#if DEBUG
        print("local path \(String(describing: basePath))")
#endif
        guard let lawsFolder = lawsFolder else { return [] }
        if !lawsFolder.isExists() || checkNeedsUpgrade() {
            self.upgradeLocalLaws()
        }
        self.removeDeletedLaws()
        do {
            return try lawsFolder.subDirectories()
                .map { $0.appendingPathComponent(LocalManager.DB_NAME)}
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
