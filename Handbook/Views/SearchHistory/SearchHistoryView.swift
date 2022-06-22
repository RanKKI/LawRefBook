import Foundation
import SwiftUI
import CoreData

struct SearchHistoryView: View {
    
    @ObservedObject
    var vm: VM
    
    @Binding
    var searchText: String
    
    var action: ((String) -> Void)?
    
    @Environment(\.managedObjectContext)
    private var moc
    
    var emptyAll: some View {
        Group {
            Text("清空")
            Image(systemName: "trash")
        }
        .onTapGesture {
            vm.removeAllHistories()
        }
    }
    
    var historiesView: some View {
        ForEach(vm.histories, id: \.id) { history in
            HStack {
                Text(history.text ?? "")
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                history.updateSearchT(moc: moc)
                action?(history.text ?? "")
            }
            .swipeActions {
                Button {
                    history.delete(moc: moc)
                    vm.loadHistories(moc: moc)
                } label: {
                    Label("删除记录", systemImage: "trash")
                }
                .tint(.red)
            }
        }
    }

    var body: some View {
        List {
            Section {
                historiesView
            } header: {
                HStack(spacing: 0) {
                    Text("搜索历史")
                    Spacer()
                    if vm.showEmptyAll{
                        emptyAll
                    }
                }
                .font(.caption)
            }
        }
        .listStyle(.plain)
        .transition(.asymmetric(insertion: .move(edge: .top), removal: .opacity))
        .onAppear {
            vm.loadHistories(moc: moc)
        }
    }
    
}
