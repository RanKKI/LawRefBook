//
//  ContentView.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation
import SwiftUI

struct ContentView: View {

    @ObservedObject
    private var sheetManager = SheetMananger<Sheets>()

    @Environment(\.managedObjectContext)
    private var moc

    var body: some View {
        VStack {
            LawListView(showFavorite: true)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                IconButton(icon: "heart.text.square") {
                    sheetManager.state = .favorite
                }
                IconButton(icon: "gear") {
                    sheetManager.state = .setting
                }
            }
        }
        .navigationTitle("中国法律")
        .sheet(isPresented: $sheetManager.isShowingSheet) {
            NavigationView {
                if sheetManager.state == .setting {
                    PreferenceView()
                        .navigationBarTitle("关于", displayMode: .inline)
                } else if sheetManager.state == .favorite {
                    FavoriteView()
                        .navigationBarTitle("书签", displayMode: .inline)
                }
            }
            .environment(\.managedObjectContext, moc)
        }
    }
}

extension ContentView {

    enum Sheets {
        case favorite
        case setting
    }

}
