import Foundation
import SwiftUI

struct ContentView: View {
    
    @State
    private var searchText: String = ""

    @ObservedObject
    private var sheetManager = SheetMananger()
    
    var body: some View {
        VStack {
            LawList(searchText: $searchText)
        }
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
        .navigationTitle("中国法律")
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
}

extension ContentView {
    
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
    
}

struct LawList: View {

    @Binding
    var searchText: String

    @ObservedObject
    private var viewModel = ViewModel()
    
    @ObservedObject
    private var provider = LawProvider.shared

    @Environment(\.isSearching)
    private var isSearching
    
    @State
    private var searchType = SearchType.catalogue

    var body: some View {
        VStack {
            if isSearching {
                SearchTypePicker(searchType: $searchType)
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.searchResults.isEmpty {
                    if !searchText.isEmpty {
                        Spacer()
                        Text("没有结果")
                    }
                    Spacer()
                } else {
                    List(viewModel.searchResults) {
                        if searchType == .fullText {
                            NaviLawLink(uuid: $0.id, searchText: searchText)
                        } else {
                            NaviLawLink(uuid: $0.id)
                        }
                    }
                }
            } else {
                List {
                    if !provider.favoriteUUID.isEmpty {
                        LawSection(section: "收藏", laws: provider.favoriteUUID.map {
                            LocalProvider.shared.getLaw($0)
                        }.filter { $0 != nil }.map { $0! })
                    }
                    ForEach(viewModel.categories) {
                        LawSection(section: $0.category, laws: $0.laws)
                    }
                }
            }
        }
        .onChange(of: isSearching) { newValue in
            if !newValue {
                searchText = ""
            }
        }
        .onChange(of: searchText) { newValue in
            viewModel.searchText(text: searchText, type: searchType)
        }
        .onChange(of: searchType) { newValue in
            viewModel.searchText(text: searchText, type: searchType)
        }
    }
}

private struct LawSection: View {

    var section: String
    var laws: [Law]
    
    var body: some View {
        Section {
            ForEach(laws) {
                NaviLawLink(uuid: $0.id)
            }
        } header: {
            Text(section)
        }
    }
}

private struct SearchTypePicker: View {
    
    @Binding
    var searchType: SearchType
    
    var body: some View {
        Picker("搜索方式", selection: $searchType) {
            ForEach(SearchType.allCases, id: \.self) {
                Text($0.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .padding(.top, 8)
    }

}

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
