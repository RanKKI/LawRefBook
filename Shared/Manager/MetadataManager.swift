//
//  MetadataManager.swift
//  RefBook
//
//  Created by Hugh Liu on 26/5/2023.
//

import Foundation

final class MetadataManager {
    
    static let shared = MetadataManager()
    static let Ext = "meta"
    
    var baseFolder: URL! { LocalManager.shared.lawsFolder }
    
    private var decoder = JSONDecoder()
    private var encoder = JSONEncoder()
    
    func read(name: String) -> PackageMetadata? {
        return self.read(path: baseFolder.appendingPathComponent(name))
    }

    func read(path: URL) -> PackageMetadata? {
        let metafile = path.appendingPathExtension(MetadataManager.Ext)
        guard let data = metafile.content else { return nil }
        do {
            return try decoder.decode(PackageMetadata.self, from: data)
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func save(meta: IPackageMetadata) -> Bool {
        let data = try? encoder.encode(meta)
        guard let data = data else { return false }

        let folder = baseFolder.appendingPathComponent(meta.name)
        let metafile = folder.appendingPathExtension(MetadataManager.Ext)
        do {
            try data.write(to: metafile)
        } catch {
            return false
        }
        return true
    }

    func needUpdate(meta newMeta: IPackageMetadata) -> Bool? {
        guard let meta = self.read(name: newMeta.name) else { return nil }
        if newMeta.update > 0 && meta.update > 0 {
            return newMeta.update > meta.update
        }
        return newMeta.hash != meta.hash
    }

}

protocol IPackageMetadata: Codable {
    var name: String { get }
    var hash: String { get }
    var update: Int { get }
}

struct PackageMetadata: IPackageMetadata {
    let name: String
    let hash: String
    let update: Int
}
