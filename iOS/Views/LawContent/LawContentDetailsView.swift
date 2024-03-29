//
//  LawContentTextView.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation
import SwiftUI

struct LawContentDetailsView: View {

    var law: TLaw

    @ObservedObject
    var content: LawContent

    @Binding
    var searchText: String

    @Binding
    var scroll: Int64?

    @Environment(\.managedObjectContext)
    private var moc

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: CGFloat(Preference.shared.lineSpacing)) {
                    LawStatusView(law: law)
                    LawTitleTextView(titles: content.titles)
                    LawBodyTextView(law: law, sections: $content.sections, searchText: $searchText)
                }
                .onChange(of: scroll) { target in
                    if let target = target {
                        scroll = nil
                        withAnimation(.easeOut(duration: 1)) {
                            proxy.scrollTo(target, anchor: .top)
                        }
                    }
                }
            }
        }
        .onAppear {
            if !searchText.isEmpty {
                content.filter(text: searchText)
            }
        }
        .onChange(of: searchText) { text in
            content.filter(text: text)
            SearchHistory.add(moc: moc, text, law.id)
        }
    }

}
