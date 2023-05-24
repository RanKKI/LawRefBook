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
    }

}

class DLCManager: ObservableObject {
    
    static let shared = DLCManager()
    
    @Published
    var isLoading = false
    
    @Published
    var isDownloading = false
    
    private func _fetch() async -> [DLC] {
        guard let url = URL(string: "https://raw.githubusercontent.com/LawRefBook/Laws/release/dlc.txt") else {
            return []
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let str = String(data: data, encoding: .utf8) else {
                return []
            }
            let arr = str.split(separator: "\n")
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
        } catch {

        }
        return []
    }
    
    func fetch() async -> [DLC] {
        uiThread {
            self.isLoading = true
        }
        let ret = await self._fetch()
        uiThread {
            self.isLoading = false
        }
        return ret
    }
    
    func _download(item: DLC, progressHandler: @escaping ((Double) -> Void)) async -> Bool{
        guard let url = item.url else {
            print("Invalid url \(item.url)")
            return false
        }
        let delegate = DLCDownloadDelegate()
        delegate.progressHandler = progressHandler
        
        guard let localPath = LocalManager.shared.cacheFolder?.appendingPathComponent(item.hashZipFilename) else {
            print("Invalid localPath")
            return false
        }

        print("Downloading \(item.url) to \(localPath)")
        var data: Data?
        do {
            (data, _ ) = try await URLSession.shared.data(from: url, delegate: delegate)
        } catch {
            print("Download Failed")
            print(error)
        }
        guard let data = data else { return false }
        do {
            try data.write(to: localPath)
            try LocalManager.shared.unzipLaw(at: localPath, name: item.name, hash: item.hash)
        } catch {
            print(error)
            return false
        }
        
        print("Downloaded")
        return true
    }

    func download(item: DLC, progressHandler: @escaping ((Double) -> Void)) async -> Bool{
        uiThread {
            self.isDownloading = true
        }
        let ret = await self._download(item: item, progressHandler: progressHandler)
        uiThread {
            self.isDownloading = false
        }
        return ret
    }
    
    func queryDLCState(dlc: DLC) -> DownloadState {
        if let hash = LocalManager.shared.getLawHash(name: dlc.name) {
            if hash.elementsEqual(dlc.hash) {
                return .ready
            } else {
                return .upgradeable
            }
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

        var urlFilename: String? { filename.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) }

        var url: URL? {
            guard let urlFilename = urlFilename else {
                return nil
            }
            return URL(string: "https://raw.githubusercontent.com/LawRefBook/Laws/release/DLC/\(urlFilename)")
        }

    }

    enum DownloadState: String {
        case none = "未知"
        case ready = "成功"
        case downloading = "正在下载"
        case downloaded = "已下载"
        case failed = "下载失败"
        case upgradeable = "有更新"

        var icon: String? {
            switch(self) {
            case .downloaded:
                return "square.and.arrow.down.on.square"
            case .failed:
                return "xmark"
            default:
                return nil
            }
        }
        
        var iconColor: Color? {
            switch(self) {
            case .downloaded:
                return .green
            case .failed:
                return .red
            default:
                return nil
            }
        }
    }
}
