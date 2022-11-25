//
//  FavoriteLawListView.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation
import SwiftUI

struct FavoriteLawListView: View {
    
    @FetchRequest(entity: FavLaw.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \FavLaw.favAt, ascending: false),
    ])
    private var favLawsResult: FetchedResults<FavLaw>

    var body: some View {
        if !favLawsResult.isEmpty {
            VStack {
                Section {
                    ForEach(favLawsResult.map { LawDatabase.shared.getLaw(uuid: $0.id) }, id: \.self?.id) { law in
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
        } else {
            Group {}
        }
    }

}
