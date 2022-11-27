//
//  LawBodyTextView.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation
import SwiftUI

struct LawBodyTextView: View {
    
    var law: TLaw
    var sections: [LawContentSection]

    @Binding
    var searchText: String

    var body: some View {
        Group {
            ForEach(sections, id: \.id) { section in
                if !section.header.isEmpty && (searchText.isEmpty || !section.paragraphs.isEmpty) {
                    LawSectionHeaderView(section: section)
                }
                if !section.paragraphs.isEmpty {
                    LawSectionTextView(section: section, searchText: $searchText)
                }
            }
        }
    }
    
}

struct LawSectionHeaderView: View {
    
    var section: LawContentSection
    
    var body: some View {
        Text(section.header)
            .displayMode(.Header, indent: section.indent)
            .id(section.id)
            .padding([.top, .bottom], 8)
    }
    
}

struct LawSectionTextView: View {
    
    var section: LawContentSection
    
    @Binding
    var searchText: String
    
    var body: some View {
        Group {
            Divider()
            ForEach(section.paragraphs, id: \.id) { paragraph in
                LawParagraphTextView(paragraph: paragraph, searchText: $searchText)
            }
        }
    }
    
}


struct LawParagraphTextView: View {
    
    var paragraph: LawParagraph
    
    @Binding
    var searchText: String
    
    var body: some View {
        VStack {
            if paragraph.text.starts(with: "<!-- TABLE -->") {
                TableView(data: paragraph.text.toTableData(), width: UIScreen.screenWidth - 32)
            } else {
                LawContentTextView(text: paragraph.text)
                    .id(paragraph.id)
            }
            Divider()
        }
    }
    
}
