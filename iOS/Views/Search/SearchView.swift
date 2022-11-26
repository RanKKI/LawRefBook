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

    @ObservedObject
    private var search: SearchPayload
    
    init(vm: VM, search: SearchPayload) {
        self.vm = vm
        self.search = search
    }

    var body: some View {
        LoadingView(isLoading: $vm.isLoading) {
            VStack {
                SearchTypeView(searchType: $vm.searchType)
                List {
                    ForEach(vm.searchResult, id: \.self.id) { law in
                        LawLinkView(law: law, searchText: search.text)
                    }
                }
            }
        }
        .onChange(of: search.submit) { val in
            if !val { return }
            vm.search(text: search.text) {
                search.afterSubmit()
            }
        }
        .onChange(of: search.text) { text in
            vm.clearSearch()
        }
    }
    
}
