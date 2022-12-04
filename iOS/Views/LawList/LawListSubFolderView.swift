//
//  LawListSubFolderView.swift
//  RefBook
//
//  Created by Hugh Liu on 21/11/2022.
//

import Foundation
import SwiftUI

struct LawListSubFolderView: View {

    let category: TCategory
    var name: String?

    var body: some View {
        NavigationLink {
            LawListView(showFavorite: false, cateogry: category.name)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(category.name)
                .listStyle(.plain)
        } label: {
            Text(name ?? category.name)
        }
    }

}
