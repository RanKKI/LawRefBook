//
//  ShareLawViewModel.swift
//  RefBook
//
//  Created by Hugh Liu on 22/6/2022.
//

import Foundation

extension ShareLawView {
    
    struct ShareContent: Hashable {
        var name: String
        var content: String
        var isSelected = true
    }

    class Model: ObservableObject {

        @Published
        var selectedContents = [ShareContent]()
        
        var rendererContents: [[ShareContent]] {
            Dictionary(grouping: selectedContents.filter { $0.isSelected }, by: \.name)
                .sorted { $0.key < $1.key }
                .map { $0.value }
        }

        init(_ contents: [ShareContent]){
            self.selectedContents = contents.sorted { $0.name < $1.name }
        }
    }
    
}
