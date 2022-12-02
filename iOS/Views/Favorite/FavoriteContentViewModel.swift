//
//  FavoriteContentViewModel.swift
//  RefBook
//
//  Created by Hugh Liu on 1/12/2022.
//

import Foundation

extension FavoriteContentView {
    
    struct ContentItem: Identifiable, Hashable {
        var id: UUID
        var content: String
        var data: FavContent
    }

    struct GroupItem: Identifiable {
        var id: UUID {
            law.id
        }
        var law: TLaw
        var contents: [ContentItem]
    }

    class VM: ObservableObject {
        
        private var contents: [FavContent]
        
        @Published
        private(set) var groupedContents: [GroupItem] = []
        
        @Published
        var isLoading = false
        
        @Published
        var shareVM = ShareLawView.VM([])

        var isEmpty: Bool {
            contents.isEmpty
        }
        
        init(contents: [FavContent]) {
            self.contents = contents
        }

        func onAppear() {
            guard groupedContents.isEmpty else {
                return
            }
            self.loadLaws()
        }

        private func loadLaws() {
            uiThread {
                self.isLoading = true
            }
            Task {
                let laws = await LawManager.shared.getLaws(ids: self.contents.map { $0.lawId! })
                var result = [GroupItem]()
                var shareItems = [ShareLawView.ShareContent]()
                for arr in contents.groupByLaw() {
                    guard let favLaw = arr.first else {
                        continue
                    }
                    guard let law = laws.first(where: { $0.id == favLaw.lawId }) else {
                        continue
                    }
                    guard let content = await LawContentManager.shared.read(law: law) else {
                        continue
                    }
                    var items = [ContentItem]()
                    for item in arr {
                        guard let text = content.getLine(line: item.line) else {
                            continue
                        }
                        guard let id = item.id else {
                            continue
                        }
                        items.append(.init(id: id, content: text, data: item))
                        shareItems.append(.init(name: law.name, content: text))
                    }
                    result.append(GroupItem(law: law, contents: items))
                }

                uiThread {
                    self.groupedContents = result
                    self.isLoading = false
                    self.shareVM.updateContents(shareItems)
                }
            }
        }

    }
    
}
