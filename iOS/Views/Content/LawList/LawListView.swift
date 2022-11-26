//
//  LawListView.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation
import SwiftUI

struct LawListView: View {
    
    var showFavorite = false
    var cateogry: String?

    @State
    private var searchText = ""

    var body: some View {
        Group {
            LawListContentView(vm: .init(category: cateogry), showFavorite: showFavorite, searchText: $searchText)
        }
        .searchable(text: $searchText)
        .onSubmit(of: .search, {
            
        })
    }

}
