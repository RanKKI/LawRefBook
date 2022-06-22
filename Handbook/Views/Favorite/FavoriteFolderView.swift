import SwiftUI

struct FavoriteFolderView: View {

    var action: ((FavFolder?) -> Void)?

    @FetchRequest(sortDescriptors: [], predicate: nil)
    private var favorites: FetchedResults<FavContent>

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.order)
    ], predicate: nil)
    private var folders: FetchedResults<FavFolder>

    private var favoriteItems: [[FavContent]] {
        Favorite.convert(favorites).map {
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
