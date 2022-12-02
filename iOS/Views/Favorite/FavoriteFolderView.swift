//
//  FavoriteFolderView.swift
//  RefBook
//
//  Created by Hugh Liu on 1/12/2022.
//

import Foundation
import SwiftUI
import CoreData

struct FavoriteFolderView: View {
    
    private var folder: FavFolder

    @State
    private var contentVM: FavoriteContentView.VM
    
    private var isEmpty: Bool { folder.contents.isEmpty }

    @State
    private var deleteConfirm = false
    
    @State
    private var sharing = false
    
    @Environment(\.managedObjectContext)
    private var moc
    
    init(folder: FavFolder) {
        self.folder = folder
        self.contentVM = .init(contents: folder.contents)
    }

    var body: some View {
        NavigationLink {
            FavoriteContentView(vm: contentVM)
                .navigationTitle(folder.name ?? "")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing){
                        IconButton(icon: "square.and.pencil") {
                            editFolderName()
                        }
                    }
                }
        } label: {
            Text(folder.name ?? "")
        }
        .swipeActions {
            Button {
                if (folder.content?.count ?? 0) <= 0 {
                    deleteFolder()
                } else {
                    deleteConfirm.toggle()
                }
            } label: {
                Label("删除文件夹", systemImage: "folder.badge.minus")
            }
            .tint(.red)
        }
        .alert("确认删除？", isPresented: $deleteConfirm) {
            Button("确定") {
                deleteFolder()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("文件夹里有 \(folder.content?.count ?? 0) 条收藏。")
        }
//        .sheet(isPresented: $sharing) {
//            ShareLawView(vm: shareVM)
//        }
    }

    func deleteFolder() {
        let contents = folder.contents.map { $0 as NSManagedObject }
        moc.delete(folder)
        contents.forEach { moc.delete($0) }
        try? moc.save()
    }
    
    private func editFolderName() {
        self.alert(config: AlertConfig(title: "修改文件夹名", placeholder: folder.name ?? "", action: { name in
            if let txt = name, !txt.isEmpty{
                folder.name = txt
                try? moc.save()
            }
        }))
    }

}

