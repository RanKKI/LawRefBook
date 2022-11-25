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
    var name: String? = nil

    var body: some View {
        NavigationLink {
            LawListView(vm: .init(category: category.name), isSubList: true)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(category.name)
                .listStyle(.plain)
        } label: {
            Text(name ?? category.name)
        }
    }

}
