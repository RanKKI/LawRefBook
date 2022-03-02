//
//  ContentView.swift
//  law.handbook
//
//  Created by Hugh Liu on 24/2/2022.
//

import SwiftUI
import CoreData

struct LawSubList: View {
    
    var sub: LawGroup
    var body: some View {
        Section(header: Text(sub.name)) {
            ForEach(sub.laws, id: \.name) { law in
                NavigationLink(destination: LawContentView(model: law.getModal()).onAppear {
                    law.getModal().load()
                }){
                    Text(law.name)
                }
            }
        }
    }
}

struct LawList: View {
    
    var lawsArr: [LawGroup] = []
    var body: some View {
        List {
            ForEach(lawsArr, id: \.name) { sub in
                LawSubList(sub: sub)
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
    
    
    @StateObject var sheetManager = SheetMananger()
    
    @State var searchText = ""
    
    var filteredLaws:  [LawGroup] {
        if searchText.isEmpty {
            return laws
        }
        return laws.filter {
            return !$0.laws.filter{$0.name.contains(searchText)}.isEmpty
        }
    }
    
    var body: some View {
        NavigationView{
            LawList(lawsArr: filteredLaws)
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
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }.previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
    }
}
