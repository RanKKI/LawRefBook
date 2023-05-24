import Foundation
import SwiftUI


struct DLCListView: View {
    
    @ObservedObject
    var vm: VM
    
    @ObservedObject
    private var manager = DLCManager.shared
    
    @State
    private var confirmToggler = false

    var body: some View {
        LoadingView(isLoading: $manager.isLoading) {
            List {
                Section {
                    ForEach(vm.DLCs) { item in
                        DLCView(item: item) {
                            vm.setDownloadItem(item: item)
                            confirmToggler.toggle()
                        }
                    }
                } header: {
                    Text("补充包")
                }

                Section {
                    ForEach(vm.readyDLCs) { item in
                        DLCView(item: item)
                    }
                } header: {
                    Text("已下载")
                }
            }
        }
        .onAppear {
            vm.onAppear()
        }
        .alert("下载补充包", isPresented: $confirmToggler, actions: {
            if vm.downloadItem != nil {
                Button("确认") {
                    vm.download()
                }
            }
            Button("取消") {
                confirmToggler = false
            }
        }) {
            Text(vm.downloadItem?.name ?? "")
        }
    }
    
}

#if DEBUG
struct DLCListView_Previews: PreviewProvider {
    static var previews: some View {
        DLCListView(vm: .init())
    }
}
#endif
