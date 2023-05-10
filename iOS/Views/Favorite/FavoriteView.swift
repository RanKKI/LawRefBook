//
//  FavoriteVieww.swift
//  RefBook
//
//  Created by Hugh Liu on 1/12/2022.
//

import Foundation
import SwiftUI

struct FavoriteView: View {

    @FetchRequest(sortDescriptors: [], predicate: nil)
    private var favorites: FetchedResults<FavContent>

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.order)
    ], predicate: nil)
    private var folders: FetchedResults<FavFolder>

    @Environment(\.managedObjectContext)
    private var moc

    private var isEmpty: Bool { favorites.isEmpty && folders.isEmpty }

    @Environment(\.editMode)
    private var editMode

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        ZStack {
            if isEmpty {
                Text("空空如也")
            } else {
                List {
                    ForEach(folders) { folder in
                        FavoriteFolderView(folder: folder)
                    }
                    .onMove { from, to in
                        var arr = folders.map { $0 }
                        arr.move(fromOffsets: from, toOffset: to)
                        arr.enumerated().forEach { $1.order = Int64($0) }
                        try? moc.save()
                    }
                    if editMode?.wrappedValue != .active {
//                        FavoriteContentView(contents: favorites.map { $0 })
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                FavoriteFolderCreateButton()
                EditButton()
            }
        }
    }

}
