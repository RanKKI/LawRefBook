//
//  DLC.swift
//  RefBook
//
//  Created by Hugh Liu on 24/5/2023.
//

import Foundation
import SwiftUI

class DLCDownloadDelegate: NSObject, URLSessionDelegate, URLSessionDownloadDelegate  {

    var progressHandler: ((Double) -> Void)?

    // Delegate method to track download progress
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Download completed \(location)")
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // Calculate and report download progress
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        progressHandler?(progress)
        print("progress update \(progress)")
    }

}

enum DLCErrors: Error {
    case invalidURL(String)
    case invalidLocalPath(String)
    case httpError(String)
}

class DLCManager: ObservableObject {

    static let shared = DLCManager()

    @Published
    var isDownloading = false
    
    @AppStorage("baseUrl")
    var baseURL = DLCManager.GITHUB

    /*
     DLC HASH -> Error
    */
    var errorMap = [String: Bool]()

    private func _fetch() async throws -> [DLC] {
        let url = baseURL.appendingPathComponent("dlc.txt")
        let (data, resp) = try await URLSession.shared.data(from: url)
        if let httpResp = resp as? HTTPURLResponse {
            if httpResp.statusCode != 200 {
                throw DLCErrors.httpError("failed to fetch dlc list")
            }
        }
        let arr = data.asUTF8String().split(separator: "\n")
        var ret = [DLC]()
        for item in arr {
            let components = item.split(separator: " ")
            if components.count != 2 {
                print("Failed to parse DLC \(item)")
                continue
            }
            ret.append(.init(name: String(components.first!), hash: String(components.last!)))
        }
        return ret
    }

    func fetch() async -> [DLC] {
        do {
            return try await self._fetch()
        } catch {
            return []
        }
    }

    private func _download(item: DLC, progressHandler: @escaping ((Double) -> Void)) async throws {
        guard let url = item.url else {
            throw DLCErrors.invalidURL(item.url?.description ?? "")
        }
        print("Downloading from \(url.description)")
        let delegate = DLCDownloadDelegate()
        delegate.progressHandler = progressHandler

        guard let localPath = LocalManager.shared.cacheFolder?.appendingPathComponent(item.hashZipFilename) else {
            throw DLCErrors.invalidLocalPath(item.hashZipFilename)
        }

        let (data, resp) = try await URLSession.shared.data(from: url, delegate: delegate)
        if let httpResp = resp as? HTTPURLResponse {
            if httpResp.statusCode != 200 {
                throw DLCErrors.httpError("failed to download zip")
            }
        }

        try data.write(to: localPath)
        try LocalManager.shared.unzipLaw(at: localPath, name: item.name, hash: item.hash)
    }

    func download(item: DLC, progressHandler: @escaping ((Double) -> Void)) async  {
        uiThread {
            self.isDownloading = true
        }
        defer {
            uiThread {
                self.isDownloading = false
            }
        }
        do {
            try await self._download(item: item, progressHandler: progressHandler)
        } catch {
            print("Failed to download \(item.name)")
            print(error)
            self.errorMap[item.hash] = true
        }
    }

    func delete(dlc: DLC, revert: Bool = false) {
        self.errorMap.removeValue(forKey: dlc.hash)
        LocalManager.shared.deleteLaw(name: dlc.name, revert: revert)
    }

    func queryDLCState(dlc: DLC) -> DownloadState {
        if LocalManager.shared.isLawPendingDelete(name: dlc.name) {
            return .delete
        }
        if let hash = LocalManager.shared.getLawHash(name: dlc.name) {
            if hash.elementsEqual(dlc.hash) {
                return .ready
            } else {
                return .upgradeable
            }
        }
        if self.errorMap[dlc.hash] != nil {
            return .failed
        }
        return .none
    }

}

extension DLCManager {

    struct DLC {
        let name: String
        let hash: String

        var filename: String { "\(name).zip" }
        var hashZipFilename: String { "\(hash).zip" }

        var urlFilename: String? { filename }

        var url: URL? {
            guard let urlFilename = urlFilename else {
                return nil
            }
            return DLCManager.shared.baseURL.appendingPathComponent("DLC").appendingPathComponent(urlFilename)
        }

    }

    enum DownloadState: String {
        case none = "未知"
        case ready = "成功"
        case downloading = "正在下载"
        case failed = "下载失败"
        case upgradeable = "有更新"
        case delete = "已删除"

        var icon: String? {
            switch(self) {
            case .upgradeable:
                return "square.and.arrow.down.on.square"
            case .failed:
                return "xmark"
            case .delete:
                return "trash"
            case .ready:
                return "checkmark"
            default:
                return nil
            }
        }

        var iconColor: Color? {
            switch(self) {
            case .ready:
                return .green
            case .failed:
                return .red
            default:
                return nil
            }
        }
    }
}


extension DLCManager {
    
    static let GITHUB = URL(string: "https://raw.githubusercontent.com/LawRefBook/Laws/release")!
    static let JSDELIVR = URL(string: "https://cdn.jsdelivr.net/gh/LawRefBook/Laws@release")!

}
