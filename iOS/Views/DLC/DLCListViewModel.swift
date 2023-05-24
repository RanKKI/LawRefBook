import Foundation

extension DLCListView {
    
    class DLCItem: ObservableObject, Identifiable {
        
        var id = UUID()

        var dlc: DLCManager.DLC
        var state: DLCManager.DownloadState
        
        var name: String { dlc.name }
        
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
        var readyDLCs = [DLCItem]()

        var downloadItem: DLCItem?
        
        var confirmTitle: String {
            downloadItem != nil ? "确认下载\(String(describing: downloadItem?.dlc.name))么？" : "似乎出了一些错误"
        }

        init() {

        }

        func onAppear() {
            self.refresh()
        }
        
        private func refresh() {
            Task.init {
                let items = await DLCManager.shared.fetch()
                var arr = [DLCItem]()
                var readyArr = [DLCItem]()
                for item in items{
                    let state = DLCManager.shared.queryDLCState(dlc: item)
                    if state == .ready || state == .upgradeable {
                        readyArr.append(.init(dlc: item, state: state))
                    } else {
                        arr.append(.init(dlc: item, state: state))
                    }
                }
                uiThread {
                    self.DLCs = arr
                    self.readyDLCs = readyArr
                }
            }
        }
        
        func setDownloadItem(item: DLCItem) {
            self.downloadItem = item
        }

        func download() {
            if DLCManager.shared.isDownloading {
                return
            }
            guard let item = self.downloadItem else {
                return
            }
            item.state = .downloading
            Task.init {
                await DLCManager.shared.download(item: item.dlc, progressHandler: ({ progress in
                    item.progress = progress
                }))
                self.refresh()
            }
        }
    }
    
}
