import Foundation
import SwiftUI

struct LawContentTitleView: View {
    
    var text: String
    var body: some View {
        Text(text)
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
            .font(.title2)
    }
}


struct LawContentHeaderView: View {
    
    var text: String
    var indent: Int
    var body: some View {
        Text(text)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .font(indent == 1 ? .headline : .subheadline)
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
}

struct LawContentLineView: View {
    
    @AppStorage("font_content")
    var contentFontSize: Int = 17

    @AppStorage("font_tracking")
    var tracking: Double = 0.6
    
    @AppStorage("font_spacing")
    var spacing: Double = 4.5

    var text: String

    @Binding
    var searchText: String
    
    @Environment(\.colorScheme)
    private var colorScheme


    func highlightText(_ str: Substring) -> Text {
        guard !str.isEmpty && !searchText.isEmpty else { return Text(str) }
        
        var result: Text!
        let parts = str.components(separatedBy: searchText)
        for i in parts.indices {
            result = (result == nil ? Text(parts[i]) : result + Text(parts[i]))
            if i != parts.count - 1 {
                result = result + Text(searchText).font(.system(size: CGFloat(contentFontSize + 2))).bold().foregroundColor(Color.accentColor)
            }
        }
        return result ?? Text(str)
    }
    
    var body: some View {
        VStack {
            let arr = text.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
            if arr.count == 1 || arr[0].range(of: "^第.+?条", options: .regularExpression) == nil {
                let range = text.startIndex..<text.endIndex
                highlightText(text[range])
                    .font(.system(size: CGFloat(contentFontSize)))
                    .tracking(tracking)
                    .lineSpacing(spacing)

            }else{
                (Text(arr[0]).bold() + Text(" ") + highlightText(arr[1]))
                    .font(.system(size: CGFloat(contentFontSize)))
                    .tracking(tracking)
                    .lineSpacing(spacing)
            }
        }
        .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}


private struct LawLineView: View {
    
    var lawID: UUID
    @ObservedObject var law: LawContent
    
    @State var text: String
    @State var line: Int64
    @State var showActions = false
    
    @Binding var searchText: String
    
    @State var selectFolderView = false
    
    var body: some View {
        Group {
            LawContentLineView(text: text, searchText: $searchText)
                .contextMenu {
                    Button {
                        selectFolderView.toggle()
                    } label: {
                        Label("收藏", systemImage: "suit.heart")
                    }
                    Button {
                        Report(law: law, line: text)
                    } label: {
                        Label("反馈", systemImage: "flag")
                    }
                    Button {
                        let title = LawProvider.shared.getLawTitleByUUID(lawID)
                        let message = String(format: "%@\n\n%@", title, text)
                        UIPasteboard.general.setValue(message, forPasteboardType: "public.plain-text")
                    } label: {
                        Label("复制", systemImage: "doc")
                    }
                }
        }.sheet(isPresented: $selectFolderView) {
            SelectFolderView(action: { folder in
                if let folder = folder {
                    LawProvider.shared.favoriteContent(lawID, line: line, folder: folder)
                }
            })
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
                LawContentTitleView(text: obj.Titles[i])
            }
        }
    }
    
    var bodyList: some View {
        ForEach(obj.Content, id: \.id) { (content: TextContent) in
            if self.searchText.isEmpty || (!self.searchText.isEmpty && !content.children.isEmpty){
                if !content.text.isEmpty {
                    LawContentHeaderView(text: content.text, indent: content.indent)
                        .id(content.line)
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }
            }
            if !content.children.isEmpty {
                Divider()
                ForEach(content.children, id:\.id) {  line in
                    LawLineView(lawID: lawID, law: obj, text: line.text, line: line.line, searchText: $searchText)
                        .id(line.line)
                        .onTapGesture {
                            print(line.line, line.text)
                        }
                    Divider()
                }
            }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 4){
                title
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing:0))
                bodyList
            }
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        }
        .onChange(of: searchText) { text in
            obj.filterText(text: searchText)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "当前法律内搜索")
        .onAppear {
            if !searchText.isEmpty {
                obj.filterText(text: searchText)
            }
        }
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

    var lawID: UUID

    @ObservedObject
    var content: LawContent

    @State
    var isFav = false
    
    var searchText: String = ""

    @State
    private var scrollTarget: Int64?
    
    @StateObject
    private var sheetManager = SheetMananger()

    var body: some View{
        ScrollViewReader { scrollProxy in
            LawContentList(lawID: lawID, obj: content, searchText: searchText)
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
                IconButton(icon: isFav ? "heart.slash" : "heart") {
                    isFav = LawProvider.shared.favoriteLaw(lawID)
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
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
