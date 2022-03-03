//
//  LawContentView.swift
//  law.handbook
//
//  Created by Hugh Liu on 26/2/2022.
//

import Foundation
import SwiftUI

struct LawInfoPage: View {

    @ObservedObject var law: LawContent
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            ForEach(law.Desc, id: \.id) { info in
                if !info.content.isEmpty {
                    Section(header: Text(info.header)){
                        Text(info.content)
                    }
                }else{
                    Text(info.header)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .listRowSeparator(.hidden)
                }
            }
        }.listStyle(.plain)
            .toolbar {
                TextBarItem("关闭") {
                    dismiss()
                }
            }
    }
}

struct LawContentList: View {

    @ObservedObject var law: LawContent
    @State var content: [TextContent] = []

    @Environment(\.managedObjectContext) var moc

    var title: some View {
        ForEach($law.Titles.indices, id: \.self) { i in
            Text(self.law.Titles[i])
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .listRowSeparator(.hidden)
                .font(i == 0 ? .title2 : .title3)
        }
    }

    func ContentLine(text: String) -> some View {
        Text(text)
            .swipeActions {
                Button {
                    Report(law: law, line: text)
                } label: {
                    Label("反馈", systemImage: "exclamationmark.circle")
                }
                .tint(.red)
                Button {
                    let fav = FavContent(context: moc)
                    fav.id = UUID()
                    fav.content = text
                    fav.law = law.Titles.first
                    try? moc.save()
                } label: {
                    Label("收藏", systemImage: "heart")
                }
                .tint(.orange)
            }
    }

    var body: some View {
        List {
            title
            ForEach(Array(law.Content.enumerated()), id: \.offset){ i, body in
                if !body.children.isEmpty {
                    Section(header: Text(body.text)){
                        ForEach(body.children, id: \.self) { text in
                            ContentLine(text: text)
                        }
                    }
                }
            }
        }.listStyle(.plain)

    }
}

struct LawContentView: View {

    var law: Law

    @State var searchText = ""
    @State var showInfoPage = false

    @EnvironmentObject var manager: LawManager

    var body: some View{
        LawContentList(law: law.getContent())
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onSubmit(of: .search) {
                law.getContent().filterText(text: searchText)
            }
            .toolbar {
                BarItem("info.circle"){
                    showInfoPage.toggle()
                }
            }
            .sheet(isPresented: $showInfoPage) {
                NavigationView {
                    LawInfoPage(law: law.getContent())
                        .navigationBarTitle("关于", displayMode: .inline)
                }

            }.id(UUID())
    }
}
