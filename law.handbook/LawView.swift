//
//  LawContentView.swift
//  law.handbook
//
//  Created by Hugh Liu on 26/2/2022.
//

import Foundation
import SwiftUI

struct LawInfoPage: View {

    @ObservedObject var model: LawModel

    var body: some View {
        List {
            ForEach(model.Desc, id: \.id) { info in
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
    }
}

struct LawContentList: View {

    @ObservedObject var model: LawModel
    @State var content: [TextContent] = []

    @Environment(\.managedObjectContext) var moc

    var title: some View {
        ForEach($model.Titles.indices, id: \.self) { i in
            Text(self.model.Titles[i])
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
                    Report(law: model, line: text)
                } label: {
                    Label("反馈", systemImage: "exclamationmark.circle")
                }
                .tint(.red)
                Button {
                    let fav = Favouite(context: moc)
                    fav.id = UUID()
                    fav.content = text
                    fav.law = model.Titles.first
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
            ForEach(Array(model.Content.enumerated()), id: \.offset){ i, body in
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

    @ObservedObject var model: LawModel

    @State var searchText = ""
    @State var showInfoPage = false

    func filterContents() {
        DispatchQueue.main.async {
            print("on serach", searchText)
            var newBody: [TextContent] = []
            model.Body.forEach { val in
                let children = val.children.filter { $0.contains(searchText) }
                newBody.append(TextContent(id: val.id, text: val.text, children: children))
            }
            model.Content = newBody
        }
    }

    var body: some View{
        LawContentList(model: model)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onSubmit(of: .search) {
                filterContents()
            }
            .onChange(of: searchText){ query in
                if query.isEmpty {
                    model.Content = model.Body
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showInfoPage.toggle()
                    }, label: {
                        Image(systemName: "info.circle")
                    }).foregroundColor(.red)
                        .sheet(isPresented: $showInfoPage) {
                            LawInfoPage(model: model)
                        }.id(UUID())
                }
            }
    }
}

struct LawContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LawContentView(model: Law(name: "消费者权益保护法").getModal())
        }.previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
    }
}

