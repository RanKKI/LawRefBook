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

    @ObservedObject
    private var search: SearchPayload

    @State
    private var vm: LawListContentView.VM
    
    init(showFavorite: Bool, cateogry: String? = nil) {
        self.showFavorite = showFavorite
        self.cateogry = cateogry
        self.search = .init()
        self.vm = .init(category: cateogry)
    }

    var body: some View {
        LawListContentView(vm: vm, showFavorite: showFavorite, search: search)
            .searchable(text: $search.text)
            .onSubmit(of: .search) {
                search.submit()
            }
    }

}
