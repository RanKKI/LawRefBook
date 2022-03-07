import Foundation
import SwiftUI

struct LawContentLine: View {

    var lawID: UUID
    @ObservedObject var law: LawContent

    @State var text: String
    @State var showActions = false

    func boldSection() -> Text {
        let arr = text.split(separator: " ")
        if arr.count == 1 {
            return Text(text)
        }
        return Text(arr[0]).bold() + Text(" " + arr[1])
    }

    var body: some View {
        boldSection()
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
                Button("复制") {
                    let message = String(format: "%@\n\n%@", LawProvider.shared.getLawTitleByUUID(lawID), text)
                    UIPasteboard.general.setValue(message, forPasteboardType: "public.plain-text")
                }
                Button("取消", role: .cancel) {

                }
            } message: {
                if text.count > 25 {
                    Text(text.prefix(upTo: text.index(text.startIndex, offsetBy: 25)) + "...")
                } else {
                    Text(text)
                }
            }
    }
}

struct LawContentList: View {

    var lawID: UUID
    @ObservedObject var obj: LawContent
    @State var content: [TextContent] = []
    @State var searchText = ""

    var title: some View {
        VStack {
            ForEach($obj.Titles.indices, id: \.self) { i in
                Text(obj.Titles[i])
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .font(i == 0 ? .title2 : .title2)
            }
        }
    }

    var bodyList: some View {
        ForEach(obj.Content, id: \.id) { (content: TextContent) in
            if self.searchText.isEmpty || (!self.searchText.isEmpty && !content.children.isEmpty){
                Text(content.text)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .id(content.line)
                    .font(content.indent == 1 ? .headline : .subheadline)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            }
            if !content.children.isEmpty {
                Divider()
                ForEach(Array(zip(content.children.indices, content.children)), id: \.0) { (i: Int, txt: String) in
                    LawContentLine(lawID: lawID, law: obj, text: txt)
                        .id(content.line + i + 1)
                    Divider()
                }
            }
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading){
                title
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing:0))
                bodyList
            }
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        }
        .onChange(of: searchText) { text in
            obj.filterText(text: searchText)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    }
}

struct LawContentView: View {

    class SheetMananger: ObservableObject{

        enum SheetState {
            case none
            case info
            case toc
        }

        @Published var isShowingSheet = false
        @Published var sheetState: SheetState = .none {
            didSet {
                withAnimation {
                    isShowingSheet = sheetState != .none
                }
            }
        }
    }

    @StateObject var sheetManager = SheetMananger()

    var lawID: UUID
    @ObservedObject var content: LawContent

    @State var isFav = false
    @State private var scrollTarget: Int?

    var body: some View{
        ScrollViewReader { scrollProxy in
            LawContentList(lawID: lawID, obj: content)
                .onChange(of: scrollTarget) { target in
                    if let target = target {
                        scrollTarget = nil
                        scrollProxy.scrollTo(target, anchor: .top)
                    }
                }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if content.hasToc() {
                    IconButton(icon: "list.bullet.rectangle") {
                        // show table of content
                        sheetManager.sheetState = .toc
                    }
                }
                IconButton(icon: "info.circle") {
                    sheetManager.sheetState = .info

                }
            }
        }
        .sheet(isPresented: $sheetManager.isShowingSheet, onDismiss: {
            sheetManager.sheetState = .none
        }) {
            NavigationView {
                if sheetManager.sheetState == .info {
                    LawInfoPage(lawID: lawID)
                        .navigationBarTitle("关于", displayMode: .inline)
                } else if sheetManager.sheetState == .toc {
                    TableOfContentView(obj: LawProvider.shared.getLawContent(lawID), sheetState: $sheetManager.sheetState, scrollID: $scrollTarget)
                        .navigationBarTitle("目录", displayMode: .inline)
                }
            }
        }
    }
}
