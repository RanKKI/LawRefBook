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
    
    private var cacheFolder: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(".cache", conformingTo: .directory)
    }

    private let builtInZipPath = Bundle.main.url(forResource: "laws", withExtension: "zip")
    private let zipHash = Bundle.main.url(forResource: "laws.zip", withExtension: "sha1")
    
    private var localHash: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent("laws.sha1", conformingTo: .fileURL)
    }

    lazy var ANIT996_LICENSE: String? = {
        InBundle.readFile(path: Bundle.main.path(forResource: "LICENSE", ofType: nil))?.asUTF8String()
    }()

    // 第一次打开 App
    // 创建目录 & 解压内置包体
    private func unzipLaws() throws {
        guard let zipPath = builtInZipPath else { return }
        guard let targetPath = baseFolder else { return }
        guard let cachePath = cacheFolder else { return }
        try Zip.unzipFile(zipPath, destination: cachePath, overwrite: true, password: nil)
        try FileManager.default.moveItem(at: cachePath, to: targetPath)
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
            #if DEBUG
            print("sha1 not exists")
            #endif
            return false
        }
        guard let localHash = localHash else {
            fatalError("invalid local path")
        }
        let local = FileManager.default.contents(atPath: localHash.relativePath)
        if local == nil || local?.asUTF8String() != sha1 {
            #if DEBUG
            print("needs upgrade")
            #endif
            return true;
        }
        return false;
    }
    
    private func afterUpgrade(){
        guard let sha1 = readSHA1() else { return }
        guard let localHash = localHash else {
            fatalError("invalid local path")
        }
        print(localHash.absoluteString)
        do {
            try sha1.data(using: .utf8)?.write(to: localHash)
        } catch {
            print(error.localizedDescription)
        }
    }

    // 获取本地所有数据库位置
    func getDatabaseFiles() -> [URL] {
        guard let root = baseFolder else { return [] }
        #if DEBUG
        print("local path \(root)")
        #endif
        if !root.isExists() || checkNeedsUpgrade() {
            do {
                self.removeAllLocalFiles();
                try self.unzipLaws()
                self.afterUpgrade()
                if let cachePath = cacheFolder {
                    try? self.removeFile(url: cachePath)
                }
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
        guard let root = baseFolder else { return }
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
