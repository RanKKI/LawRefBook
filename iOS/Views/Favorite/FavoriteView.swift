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
    
    private var isEmpty: Bool {
        favorites.isEmpty && folders.isEmpty
    }

    var body: some View {
        ZStack {
            if isEmpty {
                Text("空空如也")
            } else {
                List {
                    ForEach(folders) { folder in
                        FavoriteFolderView(folder: folder)
                    }
    //                FavoriteContentView(contents: favorites.map { $0 })
                }
            }
        }
    }
    
}
