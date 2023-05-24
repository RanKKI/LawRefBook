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

    private var basePath: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    var lawsFolder: URL? {
        basePath?.appendingPathComponent("laws", conformingTo: .directory)
    }

    var cacheFolder: URL? {
        basePath?.appendingPathComponent("cache", conformingTo: .directory)
    }

    private let builtInZipPath = Bundle.main.url(forResource: "laws", withExtension: "zip")
    private let zipHash = Bundle.main.url(forResource: "laws.zip", withExtension: "sha1")
    
    private var localHash: URL? {
        lawsFolder?.appendingPathComponent("laws.hash")
    }

    lazy var ANIT996_LICENSE: String? = {
        InBundle.readFile(path: Bundle.main.path(forResource: "LICENSE", ofType: nil))?.asUTF8String()
    }()

    func getLawHash(name: String) -> String? {
        guard let targetPath = lawsFolder?.appendingPathComponent(name) else { return nil }
        if let data = try? Data(contentsOf: targetPath.appendingPathExtension(".hash")) {
            return data.asUTF8String()
        }
        return nil
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
            try? FileManager.default.removeItem(at: targetPath)
        }
        
        if cachePath.isExists() {
            try? FileManager.default.removeItem(at: cachePath)
        }
        
        try Zip.unzipFile(zipPath, destination: cachePath, overwrite: true, password: nil)
        try FileManager.default.moveItem(at: cachePath, to: targetPath)
        if deleteZip {
            try? FileManager.default.removeItem(at: zipPath)
        }
        try? hash.data(using: .utf8)?.write(to: targetPath.appendingPathExtension(".hash"))
    }

    private func createFolders() {
        let folders = [cacheFolder, lawsFolder]
        for path in folders {
            if let path = path, !path.isExists() {
                try! FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
            }
        }
    }

    private func readSHA1() -> String? {
        guard let hashFile = zipHash else { return nil }
        // get sha1 from package
        if let data = FileManager.default.contents(atPath: hashFile.relativePath) {
            let sha1 = data.asUTF8String()
            return sha1
        }
        return nil
    }
    
    private func checkNeedsUpgrade() -> Bool {
        guard let sha1 = readSHA1() else {
            return false
        }
        guard let localHash = localHash else {
            fatalError("invalid local path")
        }
        let local = FileManager.default.contents(atPath: localHash.relativePath)
        if local == nil || local?.asUTF8String() != sha1 {
            return true;
        }
        return false;
    }

    private func upgradeLocalLaws() {
        guard let hash = self.readSHA1() else { return }
        do {
            self.removeAllLocalFiles();
            self.createFolders();
            try self.unzipLaw(at: builtInZipPath, name: "laws", hash: hash)
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
        do {
            return try lawsFolder.subDirectories()
                .map { $0.appendingPathComponent(LocalManager.defaultDatabaseName)}
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

    // 删除本地所有数据
    func removeAllLocalFiles() {
        guard let root = lawsFolder else { return }
        do {
            try removeFile(url: root)
        } catch {
            print("failed to removeAllLocalFiles \(error)")
        }
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

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
