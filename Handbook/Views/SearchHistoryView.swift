import Foundation
import SwiftUI
import CoreData

struct SearchHistoryView: View {
    
    var lawId: UUID?
    
    @Binding
    var searchText: String
    
    var action: ((String) -> Void)?
    
    @Environment(\.managedObjectContext)
    private var moc

    @State
    private var histories: [SearchHistory] = []
    
    @AppStorage("defaultSearchHistoryType")
    private var searchHistoryType = SearchHistoryType.share

    private func buildRequest(limit: Int?) -> NSFetchRequest<SearchHistory> {
        let fetchRequest = SearchHistory.fetchRequest()
        
        if searchHistoryType == .standalone {
            if let lawId = lawId {
                fetchRequest.predicate = NSPredicate(format: "lawId == %@", lawId.uuidString)
            } else {
                fetchRequest.predicate = NSPredicate(format: "lawId == nil")
            }
        }

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "searchT", ascending: false)]
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        return fetchRequest
    }

    private func requestHistories() -> [SearchHistory] {
        let req = buildRequest(limit: 10)
        return (try? moc.fetch(req)) ?? []
    }

    private func removeHistories() {
        let req = buildRequest(limit: nil)
        let arr = (try? moc.fetch(req)) ?? []
        for item in arr {
            moc.delete(item)
        }
        try? moc.save()
        histories = []
    }

    var body: some View {
        List {
            Section {
                ForEach(histories, id: \.id) { history in
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
                            histories = requestHistories()
                        } label: {
                            Label("删除记录", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
            } header: {
                HStack(spacing: 0) {
                    Text("搜索历史")
                    Spacer()
                    if !histories.isEmpty {
                        Group {
                            Text("清空")
                            Image(systemName: "trash")
                        }
                        .onTapGesture {
                            removeHistories()
                        }
                    }
                }
                .font(.caption)
            }
        }
        .listStyle(.plain)
        .transition(.asymmetric(insertion: .move(edge: .top), removal: .opacity))
        .onAppear {
            histories = requestHistories()
        }
    }
    
}
