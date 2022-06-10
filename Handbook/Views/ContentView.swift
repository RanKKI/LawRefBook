import Foundation
import SwiftUI

struct ContentView: View {

    @State
    private var searchText: String = ""

    @ObservedObject
    private var sheetManager = SheetMananger()

    @ObservedObject
    private var vm = LawList.ViewModel()

    @Environment(\.managedObjectContext)
    private var moc

    var body: some View {
        VStack {
            LawList(searchText: $searchText, viewModel: vm)
        }
        .searchable(text: $searchText, prompt: "搜索")
        .onSubmit(of: .search, {
            SearchHistory.add(moc: self.moc, searchText)
            vm.submitSearch(searchText)
        })
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
                    FavoriteFolderView()
                        .navigationBarTitle("书签", displayMode: .inline)
                }
            }
            .environment(\.managedObjectContext, moc)
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
    var vm: LawList.ViewModel

    @Binding
    var searchText: String

    @State
    var searchType: SearchType

    var body: some View {
        VStack {
            SearchTypePicker(searchType: $searchType)
            if !vm.isSubmitSearch {
                SearchHistoryView(lawId: nil, searchText: $searchText) { txt in
                    searchText = txt
                    vm.submitSearch(txt)
                }
                Spacer()
            } else if vm.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if vm.searchResults.isEmpty {
                Spacer()
                Text("没有结果")
                Spacer()
            } else {
                List(vm.searchResults) {
                    if vm.searchType == .fullText {
                        NaviLawLink(law: $0, searchText: searchText)
                    } else {
                        NaviLawLink(law: $0)
                    }
                }
            }
        }
        .onChange(of: searchType) { searchType in
            vm.searchType = searchType
            if vm.isSubmitSearch {
                vm.submitSearch(searchText)
            }
        }
        .onChange(of: searchText) { searchText in
            if searchText.isEmpty {
                vm.clearSearchState()
            }
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
    private var provider = LocalProvider.shared

    @Environment(\.isSearching)
    private var isSearching

    @AppStorage("defaultGroupingMethod", store: .standard)
    private var groupingMethod = LawGroupingMethod.department

    @FetchRequest(entity: FavLaw.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \FavLaw.favAt, ascending: false),
    ])
    private var favLawsResult: FetchedResults<FavLaw>

    var body: some View {
        VStack {
            if isSearching {
                SearchListView(vm: viewModel, searchText: $searchText, searchType: viewModel.searchType)
            } else if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                List {
                    if showFav && !favLawsResult.isEmpty {
                        FavLawSection(result: favLawsResult.map { $0 })
                    }
                    if viewModel.categories.count == 1 {
                        ForEach(viewModel.categories.first!.laws) {
                            NaviLawLink(law: $0)
                        }
                    } else {
                        ForEach(viewModel.categories) {
                            LawSection(category: $0)
                        }
                        ForEach(viewModel.folders, id: \.self) {
                            FolderSection(name: $0.first?.group ?? "", folders: $0)
                        }
                    }
                }
            }
        }
        .onChange(of: isSearching) { isSearching in
            if !isSearching {
                searchText = ""
                viewModel.clearSearchState()
            }
        }
        .onChange(of: groupingMethod) { newValue in
            viewModel.refresh(method: newValue)
        }
        .task {
            viewModel.refresh(method: groupingMethod)
        }
    }
}

private struct SpecificCategoryLink: View {

    var category: TCategory
    var name: String? = nil

    @State
    private var searchText = ""

    var body: some View {
        NavigationLink {
            LawList(searchText: $searchText,
                    viewModel: LawList.SpecificCategoryViewModal(category: category.name),
                    showFav: false)
            .searchable(text: $searchText)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(category.name)
            .listStyle(.plain)
        } label: {
            Text(name ?? category.name)
        }
    }
}

private struct FolderSection: View {

    var name: String
    var folders: [TCategory]

    var body: some View {
        Section {
            ForEach(folders) {
                SpecificCategoryLink(category: $0)
            }
        } header: {
            Text(name)
        }
    }

}

private struct FavLawSection: View {

    var result: [FavLaw]

    var body: some View {
        Section {
            ForEach(result.map {
                if let id = $0.id, let law = LawDatabase.shared.getLaw(uuid: id) {
                    return law
                }
                return nil
            }.filter { $0 != nil }.map { $0! }) { (law: TLaw) in
                NaviLawLink(law: law)
            }
        } header: {
            Text("收藏")
        }
    }
    
}

private struct LawSection: View {

    var category: TCategory
    var compress = true

    var body: some View {
        Section {
            if compress && category.laws.count > 8 {
                ForEach(category.laws[0..<min(category.laws.count, 5)]) {
                    NaviLawLink(law: $0)
                }
                if category.laws.count > 5 {
                    SpecificCategoryLink(category: category, name: "更多")
                }
            } else {
                ForEach(category.laws) {
                    NaviLawLink(law: $0)
                }
            }
        } header: {
            Text(category.name)
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
        .padding([.leading, .trailing], 16)
        .padding(.top, 8)
    }

}

struct NaviLawLink : View {

    var law: TLaw
    var searchText: String = ""

    var body: some View {
        NavigationLink {
            LawContentView(vm: LocalProvider.shared.getViewModal(law.id), searchText: searchText)
        } label: {
            VStack(alignment: .leading) {
                if let subTitle = law.subtitle {
                    if !subTitle.isEmpty {
                        Text(subTitle)
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .padding(.top, 8)
                    }
                }
                HStack {
                    if law.expired || !law.is_valid {
                        Text(law.name)
                            .foregroundColor(.gray)
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(law.expired ? .gray : .orange)
                    } else {
                        Text(law.name)
                    }
                }
                if let pub = law.publish, law.ver > 1 {
                    Text(dateFormatter.string(from: pub))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .id(law.id)
    }
}
