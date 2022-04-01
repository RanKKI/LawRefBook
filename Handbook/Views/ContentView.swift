import Foundation
import SwiftUI

struct ContentView: View {
    
    @State
    private var searchText: String = ""
    
    @ObservedObject
    private var sheetManager = SheetMananger()
    
    @ObservedObject
    private var lawListModal = LawList.ViewModel()
    
    var body: some View {
        VStack {
            LawList(searchText: $searchText, viewModel: lawListModal)
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

private struct SearchListView: View {
    
    @ObservedObject
    var viewModel: LawList.ViewModel
    
    @Binding
    var searchText: String
    
    @State
    private var searchType = SearchType.catalogue
    
    var body: some View {
        VStack {
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
        }
        
        .onChange(of: searchText) { newValue in
            viewModel.searchText(text: searchText, type: searchType)
        }
        .onChange(of: searchType) { newValue in
            viewModel.searchText(text: searchText, type: searchType)
        }
    }
}

struct LawList: View {
    
    @Binding
    var searchText: String
    
    @ObservedObject
    var viewModel: ViewModel
    
    var showFav = true
    
    @ObservedObject
    private var provider = LawProvider.shared
    
    @Environment(\.isSearching)
    private var isSearching
    
    @AppStorage("defaultGroupingMethod", store: .standard)
    private var groupingMethod = LawGroupingMethod.department
    
    var body: some View {
        VStack {
            if isSearching {
                SearchListView(viewModel: viewModel, searchText: $searchText)
            } else {
                List {
                    if showFav && !provider.favoriteUUID.isEmpty {
                        LawSection(category: LawCategory("收藏", provider.favoriteUUID.map {
                            LocalProvider.shared.getLaw($0)
                        }.filter { $0 != nil }.map { $0! }))
                    }
                    if viewModel.categories.count == 1 {
                        ForEach(viewModel.categories.first!.laws) {
                            NaviLawLink(uuid: $0.id)
                        }
                    } else {
                        ForEach(viewModel.categories) {
                            LawSection(category: $0)
                        }
                        if !viewModel.folders.isEmpty {
                            Section {
                                ForEach(viewModel.folders) {
                                    SpecificCategoryLink(category: $0)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: isSearching) { newValue in
            if !newValue {
                searchText = ""
            }
        }
        .onChange(of: groupingMethod) { newValue in
            viewModel.onGroupingChange(method: newValue)
        }
        .task {
            viewModel.onGroupingChange(method: groupingMethod)
        }
    }
}

private struct SpecificCategoryLink: View {
    
    var category: LawCategory
    var name: String? = nil
    
    @State
    private var searchText = ""
    
    var body: some View {
        NavigationLink {
            LawList(searchText: $searchText,
                    viewModel: LawList.SpecificCategoryViewModal(category: category.category),
                    showFav: false)
            .searchable(text: $searchText)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(category.category)
        } label: {
            Text(name ?? category.category)
        }
    }
}

private struct LawSection: View {
    
    var category: LawCategory
    
    var body: some View {
        Section {
            ForEach(category.laws[0..<min(category.laws.count, 5)]) {
                NaviLawLink(uuid: $0.id)
            }
            if category.laws.count > 5 {
                SpecificCategoryLink(category: category, name: "更多")
            }
        } header: {
            Text(category.category)
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
