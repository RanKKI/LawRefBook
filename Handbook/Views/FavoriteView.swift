//
//  Favorite.swift
//  law.handbook
//
//  Created by Hugh Liu on 26/2/2022.
//

import Foundation
import CoreData
import SwiftUI

private func convert(_ result: FetchedResults<FavContent>) -> [[FavContent]] {
    return Dictionary(grouping: result) { $0.lawId! }
    .sorted {
        let name1 = LawProvider.shared.getLawNameByUUID($0.value.first!.lawId!)
        let name2 = LawProvider.shared.getLawNameByUUID($1.value.first!.lawId!)
        return name1 < name2
    }
    .map { $0.value }
    .map { $0.sorted { $0.line < $1.line } }
}

private struct FavLine: View {
    
    var fav: FavContent
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        Text(LawProvider.shared.getLawContentOf(uuid: fav.lawId!, line: fav.line))
            .contextMenu {
                Button {
                    moc.delete(fav)
                    try? moc.save()
                } label: {
                    Label("取消收藏", systemImage: "heart.slash")
                        .foregroundColor(.red)
                }
            }
    }
}

private struct FavLineSection: View {
    
    @ObservedObject
    var lawContent: LawContent
    
    var section: [UUID]
    
//    LawProvider.shared.getLawTitleByUUID(section[0].lawId!)
    
    var body: some View {
        Section(header: Text()){
            ForEach(section, id: \.id) { (fav: FavContent) in
                FavLine(fav: fav)
            }
        }
    }
}

private struct FavList: View {
    
    @FetchRequest(sortDescriptors: [], predicate: nil)
    var favorites: FetchedResults<FavContent>

    var body: some View {
        List(convert(favorites), id: \.self) { (section: [FavContent]) in
            if let lawID = section.first?.lawId?
        }
    }
}

struct FavoriteView: View {

    @Environment(\.dismiss) var dismiss

    @FetchRequest(sortDescriptors: [], predicate: nil)
    var favorites: FetchedResults<FavContent>

    var body: some View {
        ZStack {
            if favorites.isEmpty {
                Text("还没有任何收藏呢～")
            } else {
                FavList()
            }
        }.toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                CloseSheetItem() {
                    dismiss()
                }
            }
        }
    }
}
