//
//  FavoriteContentView.swift
//  RefBook
//
//  Created by Hugh Liu on 1/12/2022.
//

import Foundation
import SwiftUI

struct FavoriteContentView: View {
    
    @ObservedObject
    var vm: VM

    var body: some View {
        LoadingView(isLoading: $vm.isLoading) {
            List {
                ForEach(vm.groupedContents, id: \.self) { group in
                    Section {
                        ForEach(group.contents) { item in
                            Text(item.content)
                        }
                    } header: {
                        Text(group.title)
                    }
                }
            }
        }
        .onAppear {
            vm.onAppear()
        }
    }

}

extension FavoriteContentView {
    
    struct ContentItem: Identifiable, Hashable {
        var id: UUID
        var content: String
    }

    struct GroupItem: Hashable {
        var title: String
        var contents: [ContentItem]
    }

    class VM: ObservableObject {
        
        private var contents: [FavContent]
        
        @Published
        private(set) var groupedContents: [GroupItem] = []
        
        @Published
        var isLoading = false
        
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
                let laws = await LawManager.shared.getLaws(ids: contents.map { $0.lawId! })
                var result = [GroupItem]()
                
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
                        items.append(.init(id: id, content: text))
                    }
                    result.append(GroupItem(title: law.name, contents: items))
                }

                uiThread {
                    self.groupedContents = result
                    self.isLoading = false
                }
            }
        }

    }
    
}
