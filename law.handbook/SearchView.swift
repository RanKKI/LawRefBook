//
//  SearchView.swift
//  law.handbook
//
//  Created by Hugh Liu on 26/2/2022.
//

import Foundation
import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                
                TextField("搜索", text: $searchText,
                          onEditingChanged: { isEditing in
                    
                }, onCommit: {
                    
                }).foregroundColor(.primary)
                
                Button(action: {
                    self.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill").opacity(searchText == "" ? 0 : 1)
                }
            }
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)
        }
        .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
        
    }
}

struct SearchView: View {
    
    @State private var searchText = ""
    
    var lawModel: LawModel? = nil // 如果有值，就是搜索指定文件内的
    
    var body: some View {
        VStack {
            // Search view
            SearchBar(searchText: $searchText)
            if lawModel != nil {
                LawContentList(model: lawModel!, searchText: $searchText)
            } else {
                LawList(lawsArr: laws.filter {
                    return !$0.laws.filter{$0.name.hasPrefix(searchText) || searchText == ""}.isEmpty
                })
            }
        }
    }
}


struct SearchView_Previews:PreviewProvider {
    static var previews: some View {
        Group {
            SearchView(lawModel: nil)
        }.previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
    }
}
