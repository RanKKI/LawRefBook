import Foundation
import SwiftUI
import CoreData

struct SearchHistoryView: View {

    @ObservedObject
    var vm: VM

    var action: ((String) -> Void)?

    @Environment(\.managedObjectContext)
    private var moc

    var body: some View {
        List {
            Section {
                ForEach(vm.histories, id: \.id) {
                    HistoryItem(item: $0) { text in
                        action?(text)
                    } onRemove: {
                        vm.loadHistories()
                    }
                }
            } header: {
                HistoryHeader(showEmptyALL: $vm.showEmptyAll) {
                    vm.removeAllHistories()
                }
            }
        }
        .listStyle(.plain)
        .transition(.asymmetric(insertion: .move(edge: .top), removal: .opacity))
        .onAppear {
            vm.moc = moc
            vm.loadHistories()
        }
    }

}

private struct HistoryHeader: View {

    @Binding
    var showEmptyALL: Bool

    var action: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text("搜索历史")
            Spacer()
            if showEmptyALL {
                Group {
                    Text("清空")
                    Image(systemName: "trash")
                }
                .onTapGesture {
                    action()
                }
            }
        }
        .font(.caption)
    }

}

private struct HistoryItem: View {

    var item: SearchHistory
    var action: (String) -> Void
    var onRemove: () -> Void

    @Environment(\.managedObjectContext)
    private var moc

    var body: some View {
        HStack {
            Text(item.text ?? "")
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            item.updateSearchT(moc: moc)
            if let text = item.text {
                action(text)
            }
        }
        .swipeActions {
            Button {
                item.delete(moc: moc)
                onRemove()
            } label: {
                Label("删除记录", systemImage: "trash")
            }
            .tint(.red)
        }
    }

}
