//
//  ContentView.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation
import SwiftUI
import WhatsNewKit

struct ContentView: View {

    @ObservedObject
    private var sheetManager = SheetManager<Sheets>()

    @Environment(\.managedObjectContext)
    private var moc

    @Environment(\.whatsNew)
    private var whatsNew: WhatsNewEnvironment

    var body: some View {
        Group {
            if UIDevice.isIpad {
                LawListView(showFavorite: true)
                WelcomeView()
            } else {
                HomeView()
            }
        }
        .whatsNewSheet()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if UIDevice.isIpad {
                    IconButton(icon: "heart.text.square") {
                        sheetManager.state = .favorite
                    }
                }
                IconButton(icon: "gear") {
                    sheetManager.state = .setting
                }
            }
        }
        .onAppear {
            print(whatsNew.currentVersion)
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
