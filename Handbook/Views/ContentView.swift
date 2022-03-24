import SwiftUI
import CoreData

struct NaviLawLink : View {
    
    var uuid: UUID
    var searchText: String = ""
    
    @ObservedObject
    private var law  = LawProvider.shared
    
    var body: some View {
        NavigationLink {
            LawContentView(lawID: uuid,
                           content: law.getLawContent(uuid),
                           isFav: law.getFavoriteState(uuid),
                           searchText: searchText)
            .onAppear {
                law.getLawContent(uuid).load()
            }
        } label: {
            Text(law.getLawNameByUUID(uuid))
        }
    }
}

struct LawList: View {
    
    @Binding
    var searchText: String
    
    @ObservedObject
    private var law = LawProvider.shared
    
    @Environment(\.isSearching)
    private var isSearching
    
    @State
    private var showSearching: Bool = false
    
    @State
    private var searchType: SearchType = .catalogue
    
    var sText: String {
        if searchType == .catalogue {
            return ""
        }
        return searchText
    }
    
    var body: some View {
        VStack {
            if showSearching {
                Picker("搜索方式", selection: $searchType) {
                    ForEach(SearchType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.leading, 8)
                .padding(.trailing, 8)
            }
            List {
                if !showSearching  && !law.favoriteUUID.isEmpty {
                    Section(header: Text("收藏")) {
                        ForEach(law.favoriteUUID, id: \.self) { id  in
                            NaviLawLink(uuid: id, searchText: sText)
                        }
                    }
                }
                ForEach(law.lawList, id: \.self) { ids  in
                    Section(header: Text(law.getCategoryName(ids[0]))) {
                        ForEach(ids, id: \.self) { uuid in
                            NaviLawLink(uuid: uuid, searchText: sText)
                        }
                    }
                }
            }
        }
//        .transition(.asymmetric(
//            insertion: .move(edge: .top),
//            removal: .opacity
//        ))
//        .animation(.default, value: showSearching)
        .onChange(of: searchText){ text in
            withAnimation {
                law.filterLawList(text: text, type: searchType)
            }
        }
        .onChange(of: searchType){ text in
            withAnimation {
                law.filterLawList(text: searchText, type: searchType)
            }
        }
        .onChange(of: isSearching) { val in
            withAnimation {
                showSearching = val
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
    
    @ObservedObject var law  = LawProvider.shared
    
    var body: some View {
        NavigationView{
            Group {
                LawList(searchText: $searchText)
            }
            .navigationTitle("中国法律")
            .searchable(text: $searchText, prompt: "搜索")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    IconButton(icon: "heart.text.square") {
                        sheetManager.sheetState = .favorite
                    }
                    IconButton(icon: "gear") {
                        sheetManager.sheetState = .setting
                    }
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
}
