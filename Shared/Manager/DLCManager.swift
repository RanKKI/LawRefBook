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
        uiThread {
            self.progressHandler?(progress)
        }
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
        let url = baseURL.appendingPathComponent("dlc.json")
        let (data, resp) = try await URLSession.shared.data(from: url)
        if let httpResp = resp as? HTTPURLResponse {
            if httpResp.statusCode != 200 {
                throw DLCErrors.httpError("failed to fetch dlc list")
            }
        }

        return try JSONDecoder().decode([DLC].self, from: data)
    }

    private var DLC_CACHE: [DLC] = []
    func fetch(force: Bool) async -> [DLC] {
        if force || DLC_CACHE.isEmpty {
            do {
                self.DLC_CACHE = try await self._fetch()
            } catch {

            }
        }
        return self.DLC_CACHE
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
        try LocalManager.shared.unzipLaw(at: localPath, name: item.name, hash: item.hash, updateAt: item.update)
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
        if let path = item.localSqliteFile {
            LawManager.shared.closeDB(path: path)
        }
        do {
            try await self._download(item: item, progressHandler: progressHandler)
            self.invalidateLocalLaws()
        } catch {
            print("Failed to download \(item.name)")
            print(error)
            self.errorMap[item.hash] = true
        }
    }

    func delete(dlc: DLC, revert: Bool = false) {
        self.errorMap.removeValue(forKey: dlc.hash)
        LocalManager.shared.deleteLaw(name: dlc.name, revert: revert)
        self.invalidateLocalLaws()
    }

    func queryDLCState(dlc: DLC) -> DownloadState {
        if LocalManager.shared.isLawPendingDelete(name: dlc.name) {
            return .delete
        }
        
        if let update = MetadataManager.shared.needUpdate(meta: dlc) {
            return update ? .upgradeable : .ready
        }
    
        if self.errorMap[dlc.hash] != nil {
            return .failed
        }
        return .none
    }

    private var _local_laws_flag = false
    private func invalidateLocalLaws() {
        guard !self._local_laws_flag else { return }
        self._local_laws_flag = true
    }
    
    private func validateLocalLaws() async {
        guard self._local_laws_flag else { return }
        await LawManager.shared.reconnect()
    }

    func cleanup() async {
        await self.validateLocalLaws()
    }

}

extension DLCManager {

    struct DLC: IPackageMetadata {

        let name: String
        let hash: String
        let update: Int

        var filename: String { "\(name).zip" }
        var hashZipFilename: String { "\(hash).zip" }

        var urlFilename: String? { filename }

        var url: URL? {
            guard let urlFilename = urlFilename else {
                return nil
            }
            return DLCManager.shared.baseURL.appendingPathComponent("DLC").appendingPathComponent(urlFilename)
        }
        
        var localSqliteFile: URL? {
            LocalManager.shared.lawsFolder?.appendingPathComponent(name).appendingPathComponent("db.sqlite3")
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
