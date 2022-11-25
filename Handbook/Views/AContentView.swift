import Foundation
import SwiftUI

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
                SearchHistoryView(vm: .init(nil), searchText: $searchText) { txt in
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
                        LawLinkView(law: $0, searchText: searchText)
                    } else {
                        LawLinkView(law: $0)
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
                    if viewModel.categories.count == 1 {
                        ForEach(viewModel.categories.first!.laws) {
                            LawLinkView(law: $0)
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
    
    private var vm: LawList.SpecificCategoryViewModal {
        VMCache.shared.getModel(name: category.name)
    }
    
    @Environment(\.managedObjectContext)
    private var moc

    var body: some View {
        NavigationLink {
            LawList(searchText: $searchText,
                    viewModel: VMCache.shared.getModel(name: category.name),
                    showFav: false)
            .searchable(text: $searchText)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(category.name)
            .listStyle(.plain)
            .onSubmit(of: .search, {
                SearchHistory.add(moc: self.moc, searchText)
                vm.submitSearch(searchText)
            })
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

private struct LawSection: View {

    var category: TCategory
    var compress = true

    var body: some View {
        Section {
            if compress && category.laws.count > 8 {
                ForEach(category.laws[0..<min(category.laws.count, 5)]) {
                    LawLinkView(law: $0)
                }
                if category.laws.count > 5 {
                    SpecificCategoryLink(category: category, name: "更多")
                }
            } else {
                ForEach(category.laws) {
                    LawLinkView(law: $0)
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
