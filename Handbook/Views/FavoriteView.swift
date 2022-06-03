import Foundation
import CoreData
import SwiftUI

private func convert<S>(_ result: S) -> [[FavContent]] where S: Sequence, S.Element == FavContent {
    return Dictionary(grouping: result) { $0.lawId! }
        .sorted {
            let id1 = $0.value.first!.lawId!
            let id2 = $1.value.first!.lawId!
            let laws: [TLaw] = LawDatabase.shared.getLaws(uuids: [id1, id2])
            return laws[0].name < laws[1].name
        }
        .map { $0.value }
        .map { $0.filter{ $0.line > 0 }.sorted { $0.line < $1.line } }
}

private struct FavLine: View {

    var fav: FavContent
    var content: String
    var law: TLaw

    @Environment(\.managedObjectContext)
    private var moc

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

    @State
    private var selectFolderView = false
    
    @State
    private var shareT = false

    var body: some View {
        Text(content)
            .swipeActions {
                removeFav
                .tint(.red)
            }
            .contextMenu {
                removeFav
                Button {
                    let message = String(format: "%@\n\n%@", law.name, content)
                    UIPasteboard.general.setValue(message, forPasteboardType: "public.plain-text")
                } label: {
                    Label("复制", systemImage: "doc")
                }
                Button {
                    shareT.toggle()
                } label: {
                    Label("分享", systemImage: "square.and.arrow.up")
                }
                if fav.folder == nil {
                    Button {
                        selectFolderView.toggle()
                    } label: {
                        Label("移动至文件夹", systemImage: "folder.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $selectFolderView) {
                NavigationView {
                    FavoriteFolderView(action: { folder in
                        if let folder = folder {
                            fav.folder = folder
                            try? moc.save()
                        }
                    })
                    .navigationBarTitle("选择位置", displayMode: .inline)
                    .environment(\.managedObjectContext, moc)
                }
            }
            .sheet(isPresented: $shareT) {
                NavigationView {
                    ShareByPhotoView(shareContents: [.init(name: law.name, contents: [content])])
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("分享")
                }
                .navigationViewStyle(.stack)
            }
    }
}

private struct FavLineSection: View {

    var lawID: UUID
    var law: TLaw

    @ObservedObject
    var lawContent: LawContent

    var section: [FavContent]

    var body: some View {
        Section {
            if lawContent.isLoading {
                ProgressView()
            } else {
                ForEach(section, id: \.id) { (fav: FavContent) in
                    if let content = lawContent.getLine(line: fav.line) {
                        FavLine(fav: fav, content: content, law: law)
                    }
                }
            }
        } header: {
            HStack {
                Text(law.name)
                if law.expired {
                    Image(systemName: "exclamationmark.triangle")
                }
                Spacer()
            }
        }
    }
}

private struct Sections : View {
    
    var items: [[FavContent]]
    
    var body: some View {
        ForEach(items, id: \.self) { (section: [FavContent]) in
            if let lawID = section.first?.lawId,
               let content = LocalProvider.shared.getLawContent(lawID),
               let law = LawDatabase.shared.getLaw(uuid: lawID) {
                FavLineSection(lawID: lawID,
                               law: law,
                               lawContent: content,
                               section: section)
                .onAppear {
                    content.loadAsync()
                }
            }
        }
        .transition(.slide)
    }
    
}

private struct FavFolderView: View {

    @StateObject var folder: FavFolder

    @Environment(\.managedObjectContext)
    private var moc
    
    @State
    private var shareT =  false

    private func editFolderName() {
        self.alert(config: AlertConfig(title: "修改文件夹名", placeholder: folder.name ?? "", action: { name in
            if let txt = name, !txt.isEmpty{
                folder.name = txt
                try? moc.save()
            }
        }))
    }
    
    private var folderItems: [[FavContent]]  {
        convert(folder.contents)
    }

    var body: some View {
        ZStack {
            if folder.contents.isEmpty {
                Text("空空如也")
            } else {
                List {
                    Sections(items: folderItems)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing){
                IconButton(icon: "square.and.arrow.up") {
                    shareT.toggle()
                }
                IconButton(icon: "square.and.pencil") {
                    editFolderName()
                }
            }
        }
        .sheet(isPresented: $shareT) {
            NavigationView {
                ShareByPhotoView(shareContents: folderItems.map {
                    let uuid = $0.first?.lawId ?? UUID()
                    let law = LawDatabase.shared.getLaw(uuid: uuid)
                    let content = LocalProvider.shared.getLawContent(uuid)
                    return .init(name: law?.name ?? "unknown", contents: $0.map { item in
                        return content.getLine(line: item.line)
                    })
                })
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("分享")
            }
            .navigationViewStyle(.stack)
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
                Sections(items: items)
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
