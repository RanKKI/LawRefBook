//
//  ContentView.swift
//  law.handbook
//
//  Created by Hugh Liu on 24/2/2022.
//

import SwiftUI

struct LawList: View {
    
    var lawsArr: [LawGroup] = []
    
    var action: (() -> Void)?
    
    var body: some View {
        List {
            ForEach(lawsArr, id: \.name) { g in
                Section(header: Text(g.name)) {
                    ForEach(g.laws, id: \.name) { law in
                        NavigationLink(destination: LawContentView(model: LawModel(filename:law.name, folder: law.folder)).simultaneousGesture(TapGesture().onEnded{
                            if action != nil {
                                action!()
                            }
                        })){
                            Text(law.name)
                        }
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    
    @State var showSettingModal = false
    @State var showSearchModal = false
    
    @State var searchText = ""
    
    var body: some View {
        NavigationView{
            LawList(lawsArr: laws.filter {
                return !$0.laws.filter{$0.name.hasPrefix(searchText) || searchText == ""}.isEmpty
            }).navigationBarTitle("中国法律")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSettingModal.toggle()
                        }, label: {
                            Image(systemName: "gear")
                        }).foregroundColor(.red) // You can apply colors and other modifiers too
                            .sheet(isPresented: $showSettingModal) {
                                SettingView()
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
