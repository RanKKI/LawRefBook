//
//  LawContentViewModel.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation

extension LawContentView {
    
    class VM: ObservableObject {
        
        @Published
        var isLoading = true
        
        @Published
        var searchText: String = ""

        @Published
        var law: TLaw
        
        @Published
        var content: LawContent?

        init(law: TLaw, searchText: String) {
            self.law = law
            self.searchText = searchText
        }

        func onAppear() {
            guard content == nil else {
                return
            }
            Task {
                let content = await LawContentManager.shared.read(law: law)
                uiThread {
                    self.content = content
                    self.isLoading = false
                }
            }
        }
    }
    
}
