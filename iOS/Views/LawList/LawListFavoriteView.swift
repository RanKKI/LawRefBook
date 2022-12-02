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
        Task {
            uiThread {
                self.isLoading = true
            }
            self.laws = []
            for item in results {
                guard let id = item.id else {
                    continue
                }
                guard let law = await LawManager.shared.getLaw(id: id) else {
                    continue
                }
                self.laws.append(law)
            }
            uiThread {
                withAnimation {
                    self.isLoading = false
                }
            }
        }
    }

    var body: some View {
        LoadingView(isLoading: $isLoading) {
            if !laws.isEmpty {
                Section {
                    ForEach(laws) { law in
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
            reload()
        }
    }

}

extension FetchedResults: Equatable where Element == FavLaw {
    public static func == (lhs: FetchedResults, rhs: FetchedResults) -> Bool {
        return lhs.count == rhs.count
    }
}
