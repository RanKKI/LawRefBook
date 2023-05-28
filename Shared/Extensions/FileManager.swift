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
    
    var isDirectory: Bool { (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true }
    
    var content: Data? { FileManager.default.contents(atPath: self.path) }
    
    var utf8Content: String? { content?.asUTF8String() }
    
    func remove() throws {
        if self.isExists() {
            try FileManager.default.removeItem(at: self)
        }
    }
    
    func files() throws -> [URL] {
        guard self.isDirectory else { return [] }
        return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter(\.isFileURL)
    }

    func isExists() -> Bool {
        return FileManager.default.fileExists(atPath: self.path)
    }

    func createDirectory() throws {
        try FileManager.default.createDirectory(at: self, withIntermediateDirectories: true)
    }
}

extension URL: RawRepresentable {

    public init?(rawValue: String) {
        self = URL(string: rawValue)!
    }

    public var rawValue: String {
        return self.description
    }
}
