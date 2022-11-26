//
//  LawListContentView.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation
import SwiftUI

struct LawListContentView: View {
    
    @ObservedObject
    private var vm: VM
    
    private var showFavorite = false
    
    @ObservedObject
    private var search: SearchPayload

    @Environment(\.isSearching)
    private var isSearching
    
    @State
    private var searchVM: SearchView.VM

    init(vm: VM, showFavorite: Bool, search: SearchPayload) {
        self.vm = vm
        self.showFavorite = showFavorite
        self.search = search
        self.searchVM = .init(category: vm.category)
    }

    var lawList: some View {
        List {
            if showFavorite {
                FavoriteLawListView()
            }
            ForEach(vm.categories, id: \.self) { cateogry in
                LawListCategorySectionView(label: vm.isSignleCategory ? "" : cateogry.name) {
                    LawListCategoryView(category: cateogry, showAll: vm.isSignleCategory)
                }
            }
            LawListFoldersView(folders: $vm.folders)
        }
    }

    var body: some View {
        LoadingView(isLoading: $vm.isLoading) {
            if isSearching {
                SearchView(vm: searchVM, search: search)
            } else {
                lawList
            }
        }
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
