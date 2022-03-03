//
//  ContentView.swift
//  law.handbook
//
//  Created by Hugh Liu on 24/2/2022.
//

import SwiftUI
import CoreData

struct LawSubList: View {

    var cate: LawCategory

    var body: some View {
        Section(header: Text(cate.category)) {
            ForEach(cate.laws, id: \.id) { law in
                NavigationLink(destination: LawContentView(law: law).onAppear {
                    law.getContent().load()
                }){
                    Text(law.name)
                }
            }
        }
    }
}

struct LawList: View {

    var lawsArr: [LawCategory] = []

    var body: some View {
        List {
            ForEach(lawsArr, id: \.id) { category in
                LawSubList(cate: category)
            }
        }
    }
}

struct ContentView: View {

    class SheetMananger: ObservableObject{

        enum SheetState {
            case none
            case favorite
            case setting
        }

        @Published var isShowingSheet = false
        @Published var sheetState: SheetState = .none {
            didSet {
                isShowingSheet = sheetState != .none
            }
        }
    }

    @State var searchText = ""
    @StateObject var sheetManager = SheetMananger()
    @EnvironmentObject var lawManager: LawManager

    var body: some View {
        NavigationView{
            LawList(lawsArr: lawManager.laws)
                .navigationBarTitle("中国法律")
                .toolbar {
                    BarItem("heart") {
                        sheetManager.sheetState = .favorite
                    }
                    BarItem("gear") {
                        sheetManager.sheetState = .setting
                    }
                }
                .sheet(isPresented: $sheetManager.isShowingSheet, onDismiss: {
                    sheetManager.sheetState = .none
                }) {
                    NavigationView {
                        if sheetManager.sheetState == .setting {
                            SettingView()
                                .navigationBarTitle("关于", displayMode: .inline)
                        } else if sheetManager.sheetState == .favorite {
                            FavoriteView()
                                .navigationBarTitle("收藏", displayMode: .inline)
                        }
                    }
                }
        }.searchable(text: $searchText, prompt: "宪法修正案")
            .onChange(of: searchText){ text in
                lawManager.filterLaws(filterString: text)
            }
    }

}
