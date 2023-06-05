import Foundation
import SwiftUI

struct DLCListView: View {
    
    @ObservedObject
    var vm: VM
    
    @ObservedObject
    private var manager = DLCManager.shared
    
    @State
    private var getProToggle = false;
    
    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        List {
            if vm.DLCs.isEmpty && vm.isLoading {
                ProgressView()
            }
            Section {
                if vm.DLCs.isEmpty {
                    Text("加载失败")
                } else {
                    ForEach(vm.DLCs) { item in
                        DLCView(item: item, downloadAction: {
                            vm.download(item: item)
                        }, deleteAction: {
                            vm.delete(item: item)
                        })
                    }
                }
            } header: {
                Text("DLC")
            } footer: {
                Text("点击对应法规下载")
            }
            DLCSource()
            Button {
                vm.downloadAll()
            } label: {
                Text("下载全部")
            }
            .disabled(vm.DLCs.isEmpty)
        }
        .disabled(!IsProUnlocked)
        .onAppear {
            vm.refresh();
            if !IsProUnlocked {
                getProToggle.toggle()
            }
        }
        .sheet(isPresented: $getProToggle) {
            GetProView() { val in
                if !val {
                    dismiss()
                }
            }
        }
        .onDisappear {
            Task.init {
                await manager.cleanup()
            }
        }
        .disabled(vm.isLoading || manager.isDownloading)
        .onChange(of: manager.baseURL, perform: { newValue in
            vm.refresh();
        })
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                if vm.isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "checkmark")
                        .onTapGesture {
                            vm.refresh(force: true);
                        }
                        .foregroundColor(.accentColor)
                }
            }
        })
        .navigationTitle("DLC")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}

#if DEBUG
struct DLCListView_Previews: PreviewProvider {
    static var previews: some View {
        DLCListView(vm: .init())
    }
}
#endif


private struct DLCSource: View {
    
    @ObservedObject
    private var manager = DLCManager.shared

    var body: some View {
        Section {
            DLCSourceItem(label: "源 1", url: DLCManager.GITHUB)
            DLCSourceItem(label: "源 2", url: DLCManager.JSDELIVR)
            DLCSourceItem(label: "源 3", url: DLCManager.RANKKI)
        } header: {
            Text("CDN")
        } footer: {
            Text("如果遇到网络原因，导致无法下载，可以尝试切换不同的源")
        }
    }
    
}

private struct DLCSourceItem: View {

    let label: String
    let url: URL
    
    @ObservedObject
    private var manager = DLCManager.shared

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            if url == manager.baseURL {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            manager.baseURL = url
            print("Switch CDN to \(url)")
        }
    }
    
}

