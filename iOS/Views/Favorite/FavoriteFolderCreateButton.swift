//
//  AddFavoriteFolderView.swift
//  RefBook
//
//  Created by Hugh Liu on 1/12/2022.
//

import Foundation
import SwiftUI

struct FavoriteFolderCreateButton: View {
    
    @Environment(\.managedObjectContext)
    private var moc
    
    @FetchRequest(sortDescriptors: [], predicate: nil)
    private var folders: FetchedResults<FavFolder>
    
    private func createFolder() {
        self.alert(config: AlertConfig(title: "新建文件夹", action: { name in
            guard let name = name, !name.isEmpty else {
                return
            }
            let folder = FavFolder(context: moc)
            folder.id = UUID()
            folder.name = name
            folder.order = Int64(folders.count)
            try? moc.save()
        }))
    }

    var body: some View {
        IconButton(icon: "folder.badge.plus") {
            createFolder()
        }
    }

}
