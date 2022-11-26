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
    var content: LawContent
    
    var searchText: Binding<String>
    
    private var preference = Preference.shared
    
//    init(law: TLaw, content: LawContent, searchText: Binding<String>) {
//        self.law = law
//        self.content = content
//        self.searchText = searchText
//    }
    
    init(law: TLaw, content: LawContent, searchText: Binding<String>) {
        self.law = law
        self.content = content
        self.searchText = searchText
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: CGFloat(preference.lineSpacing)) {
                    LawStatusView(law: law)
                    LawTitleTextView(titles: content.Titles)
                    LawBodyTextView(law: law, contents: content.Body, searchText: searchText)
                }
//                .onChange(of: vm.scrollPos) { target in
//                    if let target = target {
//                        vm.scrollPos = nil
//                        withAnimation(.easeOut(duration: 1)){
//                            scrollProxy.scrollTo(target, anchor: .top)
//                        }
//                    }
//                }
            }
        }
    }

}
