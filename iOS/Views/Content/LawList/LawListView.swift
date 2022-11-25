//
//  LawListView.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation
import SwiftUI

struct LawListView: View {
    
    @ObservedObject
    var vm: VM
    
    var isSubList = false

    var body: some View {
        List {
            if vm.showFavorite {
                FavoriteLawListView()
            }
            ForEach(vm.categories, id: \.self) { cateogry in
                LawListCategorySectionView(label: isSubList ? "" : cateogry.name) {
                    LawListCategoryView(category: cateogry, showAll: isSubList)
                }
            }
            LawListFoldersView(folders: $vm.folders)
        }
        .searchable(text: .constant(""))
        .onSubmit(of: .search, {

        })
        .onAppear {
            vm.onAppear()
        }
    }

}

struct LawListCategorySectionView<Content: View>: View {

    var label: String

    @ViewBuilder
    let content: () -> Content

    var body: some View {
        if label.isEmpty {
            content()
        } else {
            Section {
                content()
            } header: {
                Text(label)
            }
        }
    }
}

struct LawListCategoryView: View {
    
    let category: TCategory
    let showAll: Bool

    var body: some View {
        if category.laws.count > 8 && !showAll {
            ForEach(category.laws[0..<min(category.laws.count, 5)]) {
                LawLinkView(law: $0)
            }
            if category.laws.count > 5 {
                LawListSubFolderView(category: category, name: "更多")
            }
        } else {
            ForEach(category.laws) {
                LawLinkView(law: $0)
            }
        }
    }

}
