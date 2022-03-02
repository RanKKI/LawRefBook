//
//  Favorite.swift
//  law.handbook
//
//  Created by Hugh Liu on 26/2/2022.
//

import Foundation
import CoreData
import SwiftUI

struct FavoriteLawGroup: View {

    @Environment(\.managedObjectContext) var moc

    var arr: [FavContent]

    var body: some View {
        Section(header: Text(arr.first!.law!)){
            ForEach(arr, id:\.id){ fav in
                Text(fav.content ?? "")
                    .swipeActions {
                        Button {
                            withAnimation(.spring()){
                                moc.delete(fav)
                                try? moc.save()
                            }
                        } label: {
                            Label("移除", systemImage: "heart.slash")
                        }
                        .tint(.red)
                    }
            }
        }
    }
}

struct FavoriteView: View {

    @Environment(\.dismiss) var dismiss

    @FetchRequest(sortDescriptors: [],
                  predicate: nil,
                  animation: .default) var favorites: FetchedResults<FavContent>

    func group(_ result : FetchedResults<FavContent>)-> [[FavContent]] {
        return Dictionary(grouping: result) { $0.law! }
        .sorted {$0.value.first!.law! < $1.value.first!.law!}
        .map { $0.value }
    }

    private var favArr: Array<Array<FavContent>>  {
        return group(favorites)
    }

    var body: some View {
        ZStack {
            if favArr.isEmpty {
                Text("还没有任何收藏呢～")
            } else{
                List{
                    ForEach(Array(favArr.enumerated()), id: \.offset) { (index, arr) in
                        FavoriteLawGroup(arr: arr)
                    }
                }
            }
        }.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("关闭")
                }).foregroundColor(.red)
            }
        }
    }
}
