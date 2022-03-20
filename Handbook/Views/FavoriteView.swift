//
//  Favorite.swift
//  law.handbook
//
//  Created by Hugh Liu on 26/2/2022.
//

import Foundation
import CoreData
import SwiftUI

private func convert(_ result: [FavContent]) -> [[FavContent]] {
    return Dictionary(grouping: result) { $0.lawId! }
        .sorted {
            let name1 = LawProvider.shared.getLawNameByUUID($0.value.first!.lawId!)
            let name2 = LawProvider.shared.getLawNameByUUID($1.value.first!.lawId!)
            return name1 < name2
        }
        .map { $0.value }
        .map { $0.filter{ $0.line > 0 }.sorted { $0.line < $1.line } }
}

private func convert(_ result: FetchedResults<FavContent> ) -> [[FavContent]] {
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
    
    var body: some View {
        Text(content)
            .contextMenu {
                Button {
                    withAnimation {
                        moc.delete(fav)
                        try? moc.save()
                    }
                } label: {
                    Label("取消收藏", systemImage: "heart.slash")
                        .foregroundColor(.red)
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

    @State
    private var editNameToggler = false
    
    @Environment(\.managedObjectContext)
    private var moc
    
    var body: some View {
        ZStack {
            if(folder.contents.isEmpty ) {
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
        .navigationTitle(folder.name ?? "")
        .alert(isPresented: $editNameToggler, AlertConfig(title: "修改文件夹名", action: { name in
            if let txt = name {
                if txt.isEmpty {
                    return
                }
                folder.name = txt
                try? moc.save()
            }
        }))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing){
                IconButton(icon: "square.and.pencil") {
                    editNameToggler.toggle()
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
    
    var body: some View {
        NavigationLink {
            FavFolderView(folder: folder)
        } label: {
            Text(folder.name ?? "")
        }
        .swipeActions {
            Button {
                folder.content?.forEach {
                    moc.delete($0 as! NSManagedObject)
                }
                moc.delete(folder)
                try? moc.save()
             } label: {
                 Label("删除文件夹", systemImage: "folder.badge.minus")
             }
             .tint(.red)
        }
    }
    
}

struct FavoriteView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @FetchRequest(sortDescriptors: [], predicate: nil)
    var favorites: FetchedResults<FavContent>
    
    @FetchRequest(sortDescriptors: [], predicate: nil)
    var folders: FetchedResults<FavFolder>
    
    @Environment(\.managedObjectContext)
    private var moc
    
    @State
    private var addFolderToggle = false
    
    @State
    private var isEditing = false
    
    private var contentWithoutFolder: [[FavContent]] {
        convert(favorites).map {
            $0.filter {
                $0.folder == nil
            }
        }.filter {
            !$0.isEmpty
        }
    }
    
    var body: some View {
        Group {
            if (favorites.isEmpty && folders.isEmpty) {
                Text("空空如也")
            } else {
                List{
                    if !folders.isEmpty {
                        ForEach(folders, id: \.self) { (folder: FavFolder) in
                            FolderItemView(folder: folder)
                        }
                        .onDelete { _ in
                        
                        }
                        .onMove { from, to in

                        }
                        .contextMenu {
                            Button {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.easeIn(duration: 0.4)) {
                                        isEditing.toggle()
                                    }
                                }
                            } label: {
                                Text("修改")
                            }
                        }
                    }
                    if !isEditing {
                        ForEach(contentWithoutFolder, id: \.self) { (section: [FavContent]) in
                            if let lawID = section.first?.lawId {
                                if let content = LawProvider.shared.getLawContent(lawID) {
                                    FavLineSection(lawID: lawID, lawContent: content, section: section)
                                }
                            }
                        }
                        .transition(.slide)
                    }
                }
                .animation(.spring(), value: isEditing)
                .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
            }
        }
        .alert(isPresented: $addFolderToggle, AlertConfig(title: "新建文件夹", action: { name in
            if let txt = name {
                if txt.isEmpty {
                    return
                }
                let folder = FavFolder(context: moc)
                folder.id = UUID()
                folder.name = txt
                try? moc.save()
            }
        }))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing){
                if !isEditing {
                    IconButton(icon: "folder.badge.plus") {
                        addFolderToggle.toggle()
                    }
                    CloseSheetItem() {
                        dismiss()
                    }
                } else {
                    Button {
                        withAnimation {
                            isEditing.toggle()
                        }
                    } label: {
                        Text("完成")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}


struct SelectFolderView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @FetchRequest(sortDescriptors: [], predicate: nil)
    var folders: FetchedResults<FavFolder>
    
    @Environment(\.managedObjectContext)
    private var moc
    
    @State
    private var addFolderToggle = false
        
    var action: (FavFolder?) -> Void
    
    var body: some View {
        NavigationView {
            List(folders, id: \.self) { (folder: FavFolder) in
                HStack {
                    Text(folder.name ?? "")
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    action(folder)
                    dismiss()
                }
            }
            .navigationBarTitle("选择位置", displayMode: .inline)
            .alert(isPresented: $addFolderToggle, AlertConfig(title: "新建文件夹", action: { name in
                if let txt = name {
                    if txt.isEmpty {
                        return
                    }
                    let folder = FavFolder(context: moc)
                    folder.id = UUID()
                    folder.name = txt
                    try? moc.save()
                }
            }))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    IconButton(icon: "folder.badge.plus") {
                        addFolderToggle.toggle()
                    }
                    CloseSheetItem() {
                        dismiss()
                        action(nil)
                    }
                }
            }
        }
    }
    
}
