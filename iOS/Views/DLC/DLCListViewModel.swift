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
        var isLoading: Bool = false

        var isDeleteNoticeShow: Bool {
            DLCs.first(where: { $0.state == .delete }) != nil
        }

        init() {

        }

        func refresh(force: Bool = false) {
            uiThread {
                self.isLoading = true
            }
            Task.init {
                let items = await DLCManager.shared.fetch(force: force)
                let arr = items.map {
                    DLCItem(
                        dlc: $0,
                        state: DLCManager.shared.queryDLCState(dlc: $0)
                    )
                }
                uiThread {
                    self.isLoading = false
                    self.DLCs = arr
                }
            }
        }

        func download(item: DLCItem) {
            if DLCManager.shared.isDownloading {
                return
            }
            guard item.state != .ready else { return }
            guard item.state != .downloading else { return }
            item.state = .downloading
            Task.init {
                await DLCManager.shared.download(item: item.dlc, progressHandler: ({ progress in
                    item.progress = progress
                }))
                item.state = .none
                self.refresh()
            }
        }

        func delete(item: DLCItem) {
            guard item.state == .ready || item.state == .delete else { return }
            Task.init {
                DLCManager.shared.delete(dlc: item.dlc, revert: item.state == .delete)
                self.refresh()
            }
        }
    }

}
