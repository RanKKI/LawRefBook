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
        // Download completed
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
    var loading = false
    
    @Published
    var isDownloading = false
    
    func _download(item: DLC, progressHandler: @escaping ((Double) -> Void)) async -> Bool{
        guard let url = item.url else {
            return false
        }
        let delegate = DLCDownloadDelegate()
        delegate.progressHandler = progressHandler
        do {
            try await URLSession.shared.data(from: url, delegate: delegate)
        } catch {
            return false
        }
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

}

extension DLCManager {
    
    static let DLCs: [DLC] = [
        .init(name: "测试", hash: "123", description: "啊姥姥啊")
    ]
}

extension DLCManager {

    struct DLC {
        let name: String
        let hash: String
        let description: String
        
        var url: URL? {
            return URL(string: "")
        }

    }

    enum DownloadState: String {
        case none = "未知"
        case ready = "成功"
        case downloading = "正在下载"
        case downloaded = "已下载"
        case failed = "下载失败"

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
