import Foundation
import CoreData
import SwiftUI

private func convert<S>(_ result: S) -> [[FavContent]] where S: Sequence, S.Element == FavContent {
    return Dictionary(grouping: result) { $0.lawId! }
        .sorted {
            let name1 = LawProvider.shared.getLawNameByUUID($0.value.first!.lawId!)
            let name2 = LawProvider.shared.getLawNameByUUID($1.value.first!.lawId!)
            return name1 < name2
        }
        .map { $0.value }
        .map { $0.filter{ $0.line > 0 }.sorted { $0.line < $1.line } }
}

private struct FavLine: View {
    
    var fav: FavContent
    
    var content: String
    
    @Environment(\.managedObjectContext) var moc
    
    private var removeFav: some View {
        Button {
            withAnimation {
                moc.delete(fav)
                try? moc.save()
            }
        } label: {
            Label("取消收藏", systemImage: "heart.slash")
        }
    }
    
    var body: some View {
        Text(content)
            .swipeActions {
                removeFav
                .tint(.red)
            }
            .contextMenu {
                removeFav
                Button {
                    if let lawID = fav.lawId {
                        let title = LawProvider.shared.getLawTitleByUUID(lawID)
                        let message = String(format: "%@\n\n%@", title, content)
                        UIPasteboard.general.setValue(message, forPasteboardType: "public.plain-text")
                    }
                } label: {
                    Label("复制", systemImage: "doc")
                }
            }
    }
}

private struct FavLineSection: View {
    
    var lawID: UUID
    
    @ObservedObject
    var lawContent: LawContent
    
    var section: [FavContent]
    
    var body: some View {
        Section(header: Text(LawProvider.shared.getLawTitleByUUID(lawID))){
            ForEach(section, id: \.id) { (fav: FavContent) in
                if let content = lawContent.getLine(line: fav.line) {
                    FavLine(fav: fav, content: content)
                }
            }
        }
    }
}

private struct FavFolderView: View {
    
    @StateObject var folder: FavFolder
    
    @Environment(\.managedObjectContext)
    private var moc
    
    private func editFolderName() {
        self.alert(config: AlertConfig(title: "修改文件夹名", placeholder: folder.name ?? "", action: { name in
            if let txt = name, !txt.isEmpty{
                folder.name = txt
                try? moc.save()
            }
        }))
    }

    var body: some View {
        ZStack {
            if folder.contents.isEmpty {
                Text("空空如也")
            } else {
                List(convert(folder.contents), id: \.self) { (section: [FavContent]) in
                    if let lawID = section.first?.lawId {
                        if let content = LawProvider.shared.getLawContent(lawID) {
                            FavLineSection(lawID: lawID, lawContent: content, section: section)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing){
                IconButton(icon: "square.and.pencil") {
                    editFolderName()
                }
            }
        }
    }
}

struct FolderItemView: View {
    
    @Environment(\.managedObjectContext)
    private var moc
    
    @StateObject
    var folder: FavFolder
    
    @State
    private var deleteAlert = false
    
    func delete() {
        folder.content?.forEach {
            moc.delete($0 as! NSManagedObject)
        }
        moc.delete(folder)
        try? moc.save()
    }

    var body: some View {
        NavigationLink {
            FavFolderView(folder: folder)
                .navigationTitle(folder.name ?? "")
        } label: {
            Text(folder.name ?? "")
        }
        .swipeActions {
            Button {
                if (folder.content?.count ?? 0) <= 0 {
                    delete()
                } else {
                    deleteAlert.toggle()
                }
            } label: {
                Label("删除文件夹", systemImage: "folder.badge.minus")
            }
            .tint(.red)
        }
        .alert("确认删除？", isPresented: $deleteAlert) {
            Button("确定") {
                delete()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("文件夹里有 \(folder.content?.count ?? 0) 条收藏。")
        }
    }
    
}

private struct FavoriteContentView: View {

    var folders: [FavFolder]
        
    // 兼容之前没有分组的收藏
    var items: [[FavContent]]
    
    @Environment(\.editMode)
    private var editMode
    
    @Environment(\.managedObjectContext)
    private var moc

    var body: some View {
        List {
            ForEach(folders, id: \.self) { (folder: FavFolder) in
                FolderItemView(folder: folder)
            }
            .onMove { from, to in
                DispatchQueue.main.async(group: .none, qos: .background) {
                    var arr = folders
                    arr.move(fromOffsets: from, toOffset: to)
                    arr.enumerated().forEach {
                        $1.order = Int64($0)
                    }
                    try? moc.save()
                }
            }
            .onDelete { idx in }
            if editMode?.wrappedValue == .inactive {
                ForEach(items, id: \.self) { (section: [FavContent]) in
                    if let lawID = section.first?.lawId {
                        if let content = LawProvider.shared.getLawContent(lawID) {
                            FavLineSection(lawID: lawID, lawContent: content, section: section)
                        }
                    }
                }
                .transition(.slide)
            }
        }
    }
}

private struct SelectFolderView: View {
        
    var folders: [FavFolder]
    var onSelect: (FavFolder) -> Void

    var body: some View {
        List {
            ForEach(folders, id: \.self) { (folder: FavFolder) in
                HStack {
                    Text(folder.name ?? "")
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect(folder)
                }
            }
        }
    }
}

struct FavoriteFolderView: View {
    
    var action: ((FavFolder?) -> Void)?

    @FetchRequest(sortDescriptors: [], predicate: nil)
    private var favorites: FetchedResults<FavContent>
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.order)
    ], predicate: nil)
    private var folders: FetchedResults<FavFolder>
    
    private var favoriteItems: [[FavContent]] {
        convert(favorites).map {
            $0.filter { $0.folder == nil }
        }.filter { !$0.isEmpty }
    }
    
    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.managedObjectContext)
    private var moc

    private func createFolder() {
        self.alert(config: AlertConfig(title: "新建文件夹", action: { name in
            if let txt = name {
                if txt.isEmpty {
                    return
                }
                let folder = FavFolder(context: moc)
                folder.id = UUID()
                folder.name = txt
                folder.order = Int64(folders.count)
                try? moc.save()
            }
        }))
    }
    
    private var isSelecting: Bool {
        return action != nil
    }
    
    private var isEmpty: Bool {
        return favorites.isEmpty && folders.isEmpty
    }

    var body: some View {
        ZStack {
            if isEmpty {
                Text("空空如也")
            } else if isSelecting {
                SelectFolderView(folders: folders.map { $0 }, onSelect: { folder in
                    action?(folder)
                    dismiss()
                })
            } else {
                FavoriteContentView(folders: folders.map { $0 }, items: favoriteItems)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing){
                IconButton(icon: "folder.badge.plus") {
                    createFolder()
                }
                CloseSheetItem() {
                    dismiss()
                    action?(nil)
                }
            }
            ToolbarItemGroup(placement: .navigationBarLeading) {
                if !isSelecting && !isEmpty {
                    EditButton()
                }
            }
        }
    }
    
}
