//
//  ShareLawViewModel.swift
//  RefBook
//
//  Created by Hugh Liu on 22/6/2022.
//

import Foundation
import SwiftUI

extension ShareLawView {

    struct ShareContent: Hashable {
        var name: String
        var content: String
        var isSelected = true
    }

    class VM: ObservableObject {

        @Published
        var selectedContents = [ShareContent]()

        var rendererContents: [[ShareContent]] {
            Dictionary(grouping: selectedContents.filter { $0.isSelected }, by: \.name)
                .sorted { $0.key < $1.key }
                .map { $0.value }
        }

        var canEdit: Bool { selectedContents.count > 1 }

        @Published
        var isEditing = false

        @AppStorage("ShareByPhotoViewReviewReq")
        private var reviewReq = false

        init(_ contents: [ShareContent]) {
            self.updateContents(contents)
        }

        func updateContents(_ contents: [ShareContent]) {
            self.selectedContents = contents.sorted { $0.name < $1.name }
        }

        func afterSharing() {
            guard !reviewReq else { return }
            reviewReq.toggle()
            AppStoreReviewManager.requestReviewIfAppropriate()
        }

    }

}
