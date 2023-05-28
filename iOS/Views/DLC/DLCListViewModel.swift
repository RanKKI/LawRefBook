import Foundation

extension DLCListView {

    class DLCItem: ObservableObject, Identifiable {
        
        var id = UUID()

        var dlc: DLCManager.DLC
        
        @Published
        var state: DLCManager.DownloadState
        
        var name: String { dlc.name }
        
        @Published
        var progress: Double = 0
        
        var canDownload: Bool {
            self.state == .none || self.state == .failed || self.state == .upgradeable
        }

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

        func downloadAll() {
            Task.init {
                for item in DLCs {
                    guard item.canDownload else { continue }
                    await downloadAsync(item: item)
                }
            }
        }
        
        func download(item: DLCItem) {
            Task.init {
                await downloadAsync(item: item)
            }
        }

        private func downloadAsync(item: DLCItem) async {
            if DLCManager.shared.isDownloading {
                return
            }
            guard item.canDownload else { return }
            uiThread {
                item.state = .downloading
            }
            await DLCManager.shared.download(item: item.dlc)
            self.refresh()
        }

        func delete(item: DLCItem) {
            guard item.state == .ready || item.state == .delete || item.state == .upgradeable else { return }
            Task.init {
                DLCManager.shared.delete(dlc: item.dlc, revert: item.state == .delete)
                self.refresh()
            }
        }
    }

}
