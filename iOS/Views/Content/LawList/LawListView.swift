//
//  LawListView.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation
import SwiftUI

struct LawListView: View {
    
    private var showFavorite = false
    private var cateogry: String?

    @State
    private var search = SearchPayload()
    
    @State
    private var vm: LawListContentView.VM
    
    init(showFavorite: Bool, cateogry: String? = nil, search: SearchPayload = SearchPayload()) {
        self.showFavorite = showFavorite
        self.cateogry = cateogry
        self.search = search
        self.vm = .init(category: cateogry)
    }

    var body: some View {
        Group {
            LawListContentView(vm: vm, showFavorite: showFavorite, search: search)
        }
        .searchable(text: $search.text)
        .onSubmit(of: .search) {
            search.onSubmit()
        }
    }

}
