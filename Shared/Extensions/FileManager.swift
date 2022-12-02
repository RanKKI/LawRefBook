//
//  FileManager.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation

extension URL {

    func subDirectories() throws -> [URL] {
        guard hasDirectoryPath else { return [] }
        return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter(\.hasDirectoryPath)
    }

    func isExists() -> Bool {
        return FileManager.default.fileExists(atPath: self.path)
    }

}
