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

private struct FavList: View {
    
    var folder: FavFolder
    
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
        VStack {
            if (favorites.isEmpty && folders.isEmpty) {
                Text("空空如也")
            } else {
                List{
                    ForEach(folders, id: \.self) { (folder: FavFolder) in
                        NavigationLink {
                            FavList(folder: folder)
                        } label: {
                            Text(folder.name ?? "")
                        }
                    }
                    ForEach(contentWithoutFolder, id: \.self) { (section: [FavContent]) in
                        if let lawID = section.first?.lawId {
                            if let content = LawProvider.shared.getLawContent(lawID) {
                                FavLineSection(lawID: lawID, lawContent: content, section: section)
                            }
                        }
                    }
                }
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
                IconButton(icon: "folder.badge.plus") {
                    addFolderToggle.toggle()
                }
                CloseSheetItem() {
                    dismiss()
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
