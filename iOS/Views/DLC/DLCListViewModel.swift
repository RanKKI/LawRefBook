import Foundation

extension DLCListView {
    
    class DLCItem: ObservableObject, Identifiable {
        
        var id = UUID()

        var dlc: DLCManager.DLC
        var state: DLCManager.DownloadState
        
        var name: String { dlc.name }
        var url: String { dlc.description }
        
        @Published
        var progress: Double = 0

        init(dlc: DLCManager.DLC, state: DLCManager.DownloadState) {
            self.dlc = dlc
            self.state = state
        }

    }
    
    class VM: ObservableObject {
        
        @Published
        var DLCs = [DLCItem]()
        
        @Published
        var downloadedDLCs = [DLCItem]()

        var downloadItem: DLCItem?
        
        var confirmTitle: String {
            downloadItem != nil ? "确认下载\(String(describing: downloadItem?.dlc.name))么？" : "似乎出了一些错误"
        }
        
        init() {
            
        }

        func onAppear() {
            let dlc = DLCManager.DLCs[0]
            self.DLCs = [
                .init(dlc: dlc, state: .none),
                .init(dlc: dlc, state: .downloaded),
                .init(dlc: dlc, state: .downloading),
                .init(dlc: dlc, state: .failed),
                .init(dlc: dlc, state: .ready)
            ]
            self.downloadedDLCs = [
                .init(dlc: dlc, state: .ready),
                .init(dlc: dlc, state: .ready),
            ]
        }
        
        func setDownloadItem(item: DLCItem) {
            self.downloadItem = item
        }

        func download() {
//            if item.state == .downloaded {
//                return
//            }
//            if item.state == .downloading {
//                return
//            }
//            if item.state == .unknown {
//                return
//            }
//            Task.init {
//                await DLCManager.shared.download(item: item.dlc, progressHandler: ({ progress in
//                    
//                }))
//            }
        }
    }
    
}
