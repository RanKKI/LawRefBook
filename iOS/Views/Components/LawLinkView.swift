//
//  LawLinkView.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation
import SwiftUI

// 法律条文的入口 View，所有地方应当都用这个组件
struct LawLinkView: View {

    var law: TLaw
    var searchText: String = ""

    var body: some View {
        NavigationLink {
            LawContentView(vm: .init(law: law, searchText: searchText))
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            VStack(alignment: .leading) {
                if let subTitle = law.subtitle, !subTitle.isEmpty {
                    Text(subTitle)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .padding(.top, 8)
                }
                HStack {
                    if law.expired || !law.is_valid {
                        Text(law.name)
                            .foregroundColor(.gray)
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(law.expired ? .gray : .orange)
                    } else {
                        Text(law.name)
                    }
                }
                if let pub = law.publish, law.ver > 1 {
                    Text(dateFormatter.string(from: pub))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .id(law.id)
    }
}

struct InvalidLawLinkView: View {

    var body: some View {
        Text("该法律条文似乎消失了")
            .foregroundColor(.gray)
    }

}
