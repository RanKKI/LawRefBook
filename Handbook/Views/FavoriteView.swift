//
//  Favorite.swift
//  law.handbook
//
//  Created by Hugh Liu on 26/2/2022.
//

import Foundation
import CoreData
import SwiftUI

struct FavoriteView: View {

    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc

    @State var showActions = false
    @State var targetItem: FavContent? = nil

    @FetchRequest(sortDescriptors: [], predicate: nil)
    var favorites: FetchedResults<FavContent>

    private func convert(_ result: FetchedResults<FavContent>) -> [[FavContent]] {
        return Dictionary(grouping: result) { $0.lawId! }
        .sorted {
            let name1 = LawProvider.shared.getLawNameByUUID($0.value.first!.lawId!)
            let name2 = LawProvider.shared.getLawNameByUUID($1.value.first!.lawId!)
            return name1 < name2
        }
        .map { $0.value }
    }

    var body: some View {
        ZStack {
            if favorites.isEmpty {
                Text("还没有任何收藏呢～")
            } else {
                List(convert(favorites), id: \.self) { (section: [FavContent]) in
                    Section(header: Text(LawProvider.shared.getLawTitleByUUID(section[0].lawId!))){
                        ForEach(section, id: \.id) { (fav: FavContent) in
                            Text(fav.content ?? "")
                                .onTapGesture {
                                    self.targetItem = fav
                                    showActions.toggle()
                                }
                        }
                    }
                }
            }
        }.toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                CloseSheetItem() {
                    dismiss()
                }
            }
        }.confirmationDialog("LawActions", isPresented: $showActions) {
            Button("取消收藏") {
                moc.delete(targetItem!)
                try? moc.save()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("你要做些什么呢?")
        }
    }
}
