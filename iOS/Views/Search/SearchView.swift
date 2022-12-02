//
//  SearchView.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation
import SwiftUI

struct SearchView: View {

    @ObservedObject
    private var vm: VM

    @State
    private var historyVM: SearchHistoryView.VM

    @ObservedObject
    private var search: SearchPayload

    private var laws: [TLaw]

    init(vm: VM, search: SearchPayload, laws: [TLaw]) {
        self.vm = vm
        self.search = search
        self.laws = laws
        self.historyVM = .init()
    }

    var body: some View {
        LoadingView(isLoading: $vm.isLoading) {
            VStack {
                SearchTypeView(searchType: $vm.searchType)
                if vm.submitted {
                    SearchResultView(laws: $vm.searchResult, searchType: $vm.searchType, searchText: $search.text)
                } else {
                    SearchHistoryView(vm: historyVM) {
                        search.submit(text: $0)
                    }
                }
            }
        }
        .onChange(of: search.isSubmit) { val in
            if !val { return }
            vm.search(text: search.text, laws: laws) {
                search.afterSubmit()
            }
        }
        .onChange(of: search.text) { _ in
            vm.clearSearch()
        }
        .onChange(of: vm.searchType) { _ in
            vm.clearSearch()
        }
    }

}

private struct SearchResultView: View {

    @Binding
    var laws: [TLaw]

    @Binding
    var searchType: SearchType

    @Binding
    var searchText: String

    var body: some View {
        List {
            ForEach(laws, id: \.self.id) { law in
                LawLinkView(law: law, searchText: searchType == .fullText ? searchText : "")
            }
        }
        .listStyle(.plain)
    }

}
