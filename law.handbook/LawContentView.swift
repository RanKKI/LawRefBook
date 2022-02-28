//
//  LawContentView.swift
//  law.handbook
//
//  Created by Hugh Liu on 26/2/2022.
//

import Foundation
import SwiftUI

struct TextContent : Identifiable {
    var id: UUID = UUID()
    var text: String
    var children: [String]
}

struct Info: Identifiable {
    var id: UUID = UUID()
    var header: Substring
    var content: Substring = ""
}

extension String {
    func addNewLine(str: String) -> String {
        return self + "\n   " + str
    }
}

class LawModel: ObservableObject {

    @Published var Titles: [String] = []
    @Published var Desc: [Info] = []
    @Published var Content: [TextContent] = []
    var Body: [TextContent] = []
    
    init(law: Law) {
        var dir = "法律法条"
        if law.folder != nil {
            dir += "/" + law.folder!
        }
        var filename = law.file
        if filename == nil {
            filename = law.name
        }
        if let filepath = Bundle.main.path(forResource: filename, ofType: "md", inDirectory: dir) {
            do {
                let contents = try String(contentsOfFile: filepath)
                DispatchQueue.main.async {
                    self.parse(contents:contents)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("File not found")
        }
    }
    
    func parse(contents: String){
        let arr = contents.components(separatedBy: "\n").map{text in
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter{ line in
            return !line.isEmpty
        }
        
        var isDesc = true // 是否为信息部分
        var isFix = false // 是否为修正案
        
        for text in arr {
            let out = text.split(separator: " ", maxSplits: 1)
            if out.isEmpty {
                continue
            }
            
            if out[0] == "#" { // 标题
                Titles.append(String(out[1]))
                isFix = isFix || text.contains("修正")
                continue
            }
            
            if text.starts(with: "<!-- INFO END -->") { // 信息部分结束
                isDesc = false
                continue
            }
            
            if isDesc {
                var info = Info(header: out[0])
                if out.count > 1 {
                    info.content = out[1]
                }
                self.Desc.append(info)
                continue
            }
            
            if out[0].hasPrefix("#") { // 标题
                self.Body.append(TextContent(text: out.count > 1 ? String(out[1]) : "", children: []))
                continue
            }
            
            self.parseContent(&Body[Body.count - 1].children, text, isFix: isFix)
        }
        
        self.Content = Body
    }

    func parseContent(_ children: inout [String], _ text: String, isFix: Bool = false) {
        let matched = text.range(of: "^第.+条", options: .regularExpression) != nil
        
        if children.isEmpty || (isFix && !text.starts(with: "-")) || (!isFix && matched) {
            children.append(contentsOf: [text])
        } else {
            children[children.count - 1] = children.last!.addNewLine(str: text.trimmingCharacters(in: ["-"," "]))
        }
    }
    
}

func OpenMail(subject: String, body: String) {
    let info = String(format: "Version:%@", body, UIApplication.appVersion ?? "")
    let mailTo = String(format: "mailto:%@?subject=%@&body=%@\n\n%@", DeveloperMail, subject,body,info)
        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    let mailtoUrl = URL(string: mailTo!)!
    if UIApplication.shared.canOpenURL(mailtoUrl) {
        UIApplication.shared.open(mailtoUrl, options: [:])
    }
}

func Report(law: LawModel, line: String){
    let subject = String(format: "反馈问题:%@", law.Titles)
    let body = line
    OpenMail(subject: subject, body: body)
}

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
            LawContentView(model: LawModel(law: Law(name: "消费者权益保护法")))
        }.previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
    }
}

