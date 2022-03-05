import Foundation
import SwiftUI

struct LawContentLine: View {
    
    var lawID: UUID
    @ObservedObject var law: LawContent
//    @Environment(\.managedObjectContext) var moc

    @State var text: String
    @State var showActions = false
    
    var body: some View {
        Text(text)
            .onTapGesture {
                showActions.toggle()
            }
            .confirmationDialog("LawActions", isPresented: $showActions) {
                Button("收藏") {
                    LawProvider.shared.favoriteContent(lawID, line: text)
                }
                Button("反馈") {
                    Report(law: law, line: text)
                }
                Button("取消", role: .cancel) {
                    
                }
            } message: {
                Text("你要做些什么呢?")
            }
    }
}

struct LawContentList: View {
    
    var lawID: UUID
    @ObservedObject var obj: LawContent
    @State var content: [TextContent] = []
    @State var searchText = ""
    
    var body: some View {
        List {
            ForEach($obj.Titles.indices, id: \.self) { i in
                Text(obj.Titles[i])
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .listRowSeparator(.hidden)
                    .font(i == 0 ? .title2 : .title3)
            }
            ForEach(Array(obj.Content.enumerated()), id: \.offset){ i, body in
                if !body.children.isEmpty {
                    Section(header: Text(body.text)){
                        ForEach(body.children, id: \.self) { text in
                            LawContentLine(lawID: lawID, law: obj, text: text)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .onChange(of: searchText) { text in
            obj.filterText(text: searchText)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        
    }
}

struct LawContentView: View {
    
    var lawID: UUID
    
    @State var showInfoPage = false
    
    var body: some View{
        LawContentList(lawID: lawID, obj: LawProvider.shared.getLawContent(lawID))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    IconButton(icon: "info.circle") {
                        showInfoPage.toggle()
                    }
                }
            }
            .sheet(isPresented: $showInfoPage) {
                NavigationView {
                    LawInfoPage(lawID: lawID)
                        .navigationBarTitle("关于", displayMode: .inline)
                }
                
            }.id(UUID())
    }
}
