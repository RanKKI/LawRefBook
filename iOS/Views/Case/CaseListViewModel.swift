//
//  CaseListViewModel.swift
//  RefBook
//
//  Created by Hugh Liu on 9/5/2023.
//

import Foundation

extension CasesView {
    
    class VM: ObservableObject {
        
        @Published
        var laws = [TLaw]()
        
        let limit: Int?
        
        init(limit: Int? = nil) {
            self.limit = limit
        }
        
        func load() {
            guard laws.isEmpty else { return }
            Task.init {
                var cases = await LawManager.shared.getCases()
                if !cases.isEmpty {
                    if let limit = self.limit {
                        cases = Array(cases.prefix(limit))
                    } else {
                        let firstN = cases.dropFirst(10)
                        cases = cases + firstN.prefix(10)
                    }
                    uiThread {
                        self.laws = cases;
                    }
                }
            }
        }

    }
    
}
