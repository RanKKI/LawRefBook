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
                    LawSectionTextView(law: law, section: section, searchText: $searchText)
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
    
    var law: TLaw
    var section: LawContentSection
    
    @Binding
    var searchText: String
    
    var body: some View {
        Group {
            Divider()
            ForEach(section.paragraphs, id: \.id) { paragraph in
                LawParagraphTextView(law: law, paragraph: paragraph, searchText: $searchText)
            }
        }
    }
    
}


struct LawParagraphTextView: View {
    
    var law: TLaw
    var paragraph: LawParagraph
    
    @Binding
    var searchText: String
    
    @State
    private var saveToFavorite = false
    
    @State
    private var sharing = false
    
    @Environment(\.managedObjectContext)
    private var moc
    
    var body: some View {
        Group {
            if paragraph.text.starts(with: "<!-- TABLE -->") {
                TableView(data: paragraph.text.toTableData(), width: UIScreen.screenWidth - 32)
            } else {
                LawContentTextView(text: paragraph.text)
                    .id(paragraph.id)
            }
            Divider()
        }
        .contextMenu {
            Button {
                saveToFavorite.toggle()
            } label: {
                Label("收藏", systemImage: "heart.text.square")
            }
            CopyLawTextButton(law: law, text: paragraph.text)
            ShareButton(sharing: $sharing)
        }
        .sheet(isPresented: $saveToFavorite) {
            FavoriteFolderSelectionView { folder in
                guard let folder = folder else {
                    return
                }
                let item = FavContent(context: moc)
                item.id = UUID()
                item.lawId = law.id
                item.line = paragraph.line
                item.folder = folder
                try? moc.save()
            }
        }
        .sheet(isPresented: $sharing) {
            ShareLawView(vm: .init([.init(name: law.name, content: paragraph.text)]))
        }
    }
    
}
