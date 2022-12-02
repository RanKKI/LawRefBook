//
//  FavoriteLawListView.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation
import SwiftUI

struct LawListFavoriteView: View {

    @FetchRequest(entity: FavLaw.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \FavLaw.favAt, ascending: false)
    ])
    private var results: FetchedResults<FavLaw>

    @State
    private var laws = [TLaw]()

    @State
    private var isLoading = true

    func reload() {
        guard laws.count != results.count else { return }
        uiThread {
            self.isLoading = true
        }
        Task {
            var result = [TLaw]()
            for item in results {
                guard let id = item.id else { continue }
                guard let law = await LawManager.shared.getLaw(id: id) else {
                    continue
                }
                result.append(law)
            }
            uiThread {
                self.laws = result
                withAnimation {
                    self.isLoading = false
                }
            }
        }
    }

    func reloadOnce() {
        guard laws.isEmpty else { return }
        reload()
    }

    var body: some View {
        LoadingView(isLoading: $isLoading) {
            if !laws.isEmpty {
                Section {
                    ForEach(laws, id: \.id) { law in
                        if let law = law {
                            LawLinkView(law: law)
                        } else {
                            InvalidLawLinkView()
                        }
                    }
                } header: {
                    Text("收藏")
                }
            }
        }
        .transition(.slide)
        .onChange(of: isLoading) { _ in

        }
        .onChange(of: results) { _ in
            reload()
        }
        .task {
            reloadOnce()
        }
    }

}

extension FetchedResults: Equatable where Element == FavLaw {
    public static func == (lhs: FetchedResults, rhs: FetchedResults) -> Bool {
        return lhs.count == rhs.count
    }
}
