import Foundation
import CoreData
import SwiftUI

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
                    ShareLawView(vm: .init([.init(name: law.name, content: content)]))
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

    var lawContent: LawContent

    var section: [FavContent]

    var body: some View {
        Section {
//            if lawContent.isLoading {
//                ProgressView()
//            } else {
//                ForEach(section, id: \.id) { (fav: FavContent) in
//                    if let content = lawContent.getLine(line: fav.line) {
//                        FavLine(fav: fav, content: content, law: law)
//                    }
//                }
//            }
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
//            if let lawID = section.first?.lawId,
//               let content = LocalProvider.shared.getLawContent(lawID),
//               let law = LawDatabase.shared.getLaw(uuid: lawID) {
//                FavLineSection(lawID: lawID,
//                               law: law,
//                               lawContent: content,
//                               section: section)
//                .onAppear {
//                    content.loadAsync()
//                }
//            }
        }
        .transition(.slide)
    }
    
}

private struct FavFolderView: View {

    @StateObject
    var folder: FavFolder

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
        Favorite.convert(folder.contents)
    }
    
    private var shareContents: [ShareLawView.ShareContent] {
//        folderItems.map {
//            let uuid = $0.first?.lawId ?? UUID()
//            let law = LawDatabase.shared.getLaw(uuid: uuid)
//            let content = LocalProvider.shared.getLawContent(uuid)
//            return $0.map { item in
//                ShareLawView.ShareContent(name: law?.name ?? "", content: content.getLine(line: item.line))
//            }
//        }
//        .reduce([], { $0 + $1 })
        return []
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
                ShareLawView(vm: .init(shareContents))
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

struct FavoriteContentView: View {

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
