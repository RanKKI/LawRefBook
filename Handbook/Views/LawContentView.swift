import Foundation
import SwiftUI
import SPAlert

extension Text {
    func center() -> some View {
        self.frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
    }

    // 内容标题
    func contentTitle() -> some View {
        self
            .center()
            .font(.title2)
            .padding([.bottom], 8)
    }

    // 子标题
    // 比如 第 n 章
    func contentHeader(indent: Int) -> some View {
        self
            .center()
            .font(indent == 1 ? .headline : .subheadline)
            .padding([.bottom], 8)
    }
}

fileprivate extension Text {
    func highlight(size: CGFloat) -> Text {
        self.font(.system(size: size)).bold().foregroundColor(Color.accentColor)
    }
}

struct LawContentLineView: View {

    @AppStorage("font_content")
    var contentFontSize: Int = FontSizeDefault

    @AppStorage("font_tracking")
    var tracking: Double = FontTrackingDefault

    @AppStorage("font_spacing")
    var spacing: Double = FontSpacingDefault

    var text: String

    @Binding
    var searchText: String

    @Environment(\.colorScheme)
    private var colorScheme


    func highlightText(_ str: Substring) -> Text {
        guard !str.isEmpty && !searchText.isEmpty else { return Text(str) }

        var highlightTexts = searchText.tokenised()
        if !highlightTexts.contains(searchText) {
            highlightTexts.append(searchText)
        }
        var result: Text!
        let parts = str.components(separatedBy: highlightTexts)
        for part in parts {
            let isKeyword = highlightTexts.contains(part)
            var text = Text(part)
            if isKeyword {
                text = text.highlight(size: CGFloat(contentFontSize + 2))
            }
            result = result == nil ? text : (result + text)
        }
        return result ?? Text(str)
    }

    var body: some View {
        VStack {
            let arr = text.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
            if arr.count == 1 || arr[0].range(of: lineStartRe, options: .regularExpression) == nil {
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
        .background(colorScheme == .dark ? Color.clear : Color.white)
    }
}


private struct LawLineView: View {

    var law: TLaw

    @State var text: String
    @State var line: Int64
    @State var showActions = false

    @Binding
    var searchText: String

    @State
    private var selectFolderView = false
    
    @State
    private var shareT = false

    @Environment(\.managedObjectContext)
    private var moc

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
                        Report(law: law, content: text)
                    } label: {
                        Label("反馈", systemImage: "flag")
                    }
                    Button {
                        let title = law.name
                        let message = String(format: "%@\n\n%@", title, text)
                        UIPasteboard.general.setValue(message, forPasteboardType: "public.plain-text")
                    } label: {
                        Label("复制", systemImage: "doc")
                    }
//                    Button {

//                    } label: {
//                        Label("发送至", systemImage: "square.and.arrow.up")
//                    }
                    Button {
                        shareT.toggle()
                    } label: {
                        Label("分享", systemImage: "square.and.arrow.up")
                    }
                }
        }
        .sheet(isPresented: $selectFolderView) {
            NavigationView {
                FavoriteFolderView(action: { folder in
                    if let folder = folder {
                        FavContent.new(moc: moc, law.id, line: line, folder: folder)
                        let alertView = SPAlertView(title: "添加成功", preset: .done)
                        alertView.present(haptic: .success)
                    }
                })
                .navigationViewStyle(.stack)
                .navigationBarTitle("选择位置", displayMode: .inline)
                .environment(\.managedObjectContext, moc)
            }
        }
        .sheet(isPresented: $shareT) {
            NavigationView {
                ShareLawView(vm: .init([.init(name: law.name, content: text)]))
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("分享")
            }
            .navigationViewStyle(.stack)
        }
    }
}


private struct LawContentList: View {

    @ObservedObject
    var vm: LawContentView.LawContentViewModel

    @Binding
    var searchText: String

    @Environment(\.isSearching)
    private var isSearching

    @AppStorage("font_line_spacing")
    private var lineSpacing: Int = FontLineSpacingDefault


    var contentView: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: CGFloat(lineSpacing)) {
                    if vm.law.expired || !vm.law.is_valid {
                        HStack {
                            Spacer()
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(vm.law.expired ? .gray : .orange)
                            Text(vm.law.expired ? "本法规已废止" : "本法规暂未施行")
                            Spacer()
                        }
                        .padding([.bottom], 8)
                    }
                    ForEach(vm.titles, id: \.self) {
                        Text($0).contentTitle()
                    }
                    ForEach(vm.body, id: \.id) { paragraph in
                        if !paragraph.text.isEmpty && (searchText.isEmpty || !paragraph.children.isEmpty) {
                            Text(paragraph.text).contentHeader(indent: paragraph.indent)
                                .id(paragraph.line)
                                .padding([.top, .bottom], 8)
                        }
                        if !paragraph.children.isEmpty {
                            Divider()
                            ForEach(paragraph.children, id: \.id) { line in
                                if line.text.starts(with: "<!-- TABLE -->") {
                                    TableView(data: line.text.toTableData(), width: UIScreen.screenWidth - 32)
                                } else {
                                    LawLineView(law: vm.law, text: line.text, line: line.line, searchText: $searchText)
                                        .id(line.line)
                                }
                                Divider()
                            }
                        }
                    }
                }
            }
            .onChange(of: vm.scrollPos) { target in
                if let target = target {
                    vm.scrollPos = nil
                    withAnimation(.easeOut(duration: 1)){
                        scrollProxy.scrollTo(target, anchor: .top)
                    }
                }
            }
        }
    }

    var body: some View {
        Group {
            if isSearching && !vm.isSearchSubmit {
                SearchHistoryView(vm: .init(vm.lawID), searchText: $searchText) { txt in
                    vm.doSearchText(txt)
                    searchText = txt
                }
            } else if vm.body.isEmpty {
                Spacer()
                Text("没有结果").center()
                Spacer()
            } else {
                contentView
                    .padding([.leading, .trailing], 8)
            }
        }
        .onChange(of: isSearching) { isSearching in
            if !isSearching {
                vm.clearSearchState()
            }
        }
        .onChange(of: searchText) { searchText in
            if vm.isSearchSubmit && searchText != vm.searchText {
                vm.clearSearchState()
            }
        }
    }
}

struct LawContentView: View {
    
    enum SheetState {
        case none
        case info
        case toc
    }

    @ObservedObject
    var vm: LawContentViewModel

    @State
    var searchText: String = ""

    @StateObject
    private var sheetManager = SheetMananger<SheetState>()

    @Environment(\.managedObjectContext)
    private var moc

    var body: some View{
        VStack {
            if vm.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                LawContentList(vm: vm, searchText: $searchText)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !searchText.isEmpty && vm.searchText != searchText {
                vm.doSearchText(searchText)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if vm.hasToc {
                    IconButton(icon: "list.bullet.rectangle") {
                        sheetManager.state = .toc
                    }
                    .transition(.opacity)
                }
                IconButton(icon: vm.isFav ? "heart.slash" : "heart") {
                    vm.onFavIconClicked(moc: moc)
                }
                IconButton(icon: "info.circle") {
                    sheetManager.state = .info
                }
            }
        }
        .onAppear {
            vm.onAppear()
            vm.checkFavState(moc: moc)
        }
        .onDisappear {
            vm.clearSearchState()
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "当前法律内搜索")
        .onSubmit(of: .search) {
            SearchHistory.add(moc: self.moc, searchText, vm.lawID)
            vm.doSearchText(searchText)
        }
        .onChange(of: searchText) { text in
            if text.isEmpty {
                vm.clearSearchState()
            }
        }
        .sheet(isPresented: $sheetManager.isShowingSheet, onDismiss: {
            sheetManager.close()
        }) {
            NavigationView {
                if sheetManager.state == .info {
                    LawInfoPage(lawID: vm.lawID, toc: vm.content.Infomations)
                        .navigationBarTitle("关于", displayMode: .inline)
                } else if sheetManager.state == .toc {
                    TableOfContentView(vm: vm, sheet: sheetManager)
                        .navigationBarTitle("目录", displayMode: .inline)
                }
            }
            .phoneOnlyStackNavigationView()
        }
    }
}
