//
//  FavoriteFolderView.swift
//  RefBook
//
//  Created by Hugh Liu on 1/12/2022.
//

import Foundation
import SwiftUI

struct FavoriteFolderView: View {
    
    private var folder: FavFolder

    @State
    private var contentVM: FavoriteContentView.VM
    
    private var isEmpty: Bool { folder.contents.isEmpty }
    
    init(folder: FavFolder) {
        self.folder = folder
        self.contentVM = .init(contents: folder.contents)
    }

    var body: some View {
        NavigationLink {
            if isEmpty {
                ZStack {
                    Text("空空如也")
                }
            } else {
                FavoriteContentView(vm: contentVM)
                    .navigationTitle(folder.name ?? "")
                    .navigationBarTitleDisplayMode(.inline)
            }
        } label: {
            Text(folder.name ?? "")
        }
    }
    
}

