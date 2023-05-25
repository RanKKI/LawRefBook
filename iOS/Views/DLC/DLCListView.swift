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
        List {
            Section {
                if vm.isDeleteNoticeShow {
                    Text("删除的 DLC 会在下次进入 App 时从本地删除。你可以再次点击，从而撤销删除。")
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .multilineTextAlignment(.leading)
            .font(.footnote)

            Section {
                ForEach(vm.DLCs) { item in
                    DLCView(item: item, downloadAction: {
                        vm.download(item: item)
                    }, deleteAction: {
                        vm.delete(item: item)
                    })
                }
            } header: {
                Text("DLC")
            }
            DLCSource()
        }
        .onAppear {
            vm.refresh();
        }
        .disabled(vm.isLoading)
        .onChange(of: manager.baseURL, perform: { newValue in
            vm.refresh();
        })
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                if vm.isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "arrow.clockwise")
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
            DLCSourceItem(label: "GitHub", url: DLCManager.GITHUB)
            DLCSourceItem(label: "jsDelivr", url: DLCManager.JSDELIVR)
        } header: {
            Text("源")
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
        }
    }
    
}

