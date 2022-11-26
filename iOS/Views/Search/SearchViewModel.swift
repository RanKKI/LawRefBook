//
//  SearchViewModel.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation

extension SearchView {
    
    final class VM: ObservableObject {
        
        @Published
        var searchType: SearchType = .catalogue

        
    }
    
}
