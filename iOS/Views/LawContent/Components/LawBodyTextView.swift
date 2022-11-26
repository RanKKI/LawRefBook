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
    var contents: [TextContent]
    
    @Binding
    var searchText: String

    var body: some View {
        Text("")
//        VStack {
//            ForEach(body, id: \.id) { paragraph in
//                if !paragraph.text.isEmpty && (searchText.isEmpty || !paragraph.children.isEmpty) {
//                    Text(paragraph.text).displayMode(.Header, indent: paragraph.indent)
//                        .id(paragraph.line)
//                        .padding([.top, .bottom], 8)
//                }
//                if !paragraph.children.isEmpty {
//                    Divider()
//                    ForEach(paragraph.children, id: \.id) { line in
//                        Text(line.text)
//                        if line.text.starts(with: "<!-- TABLE -->") {
//                            TableView(data: line.text.toTableData(), width: UIScreen.screenWidth - 32)
//                        } else {
//                            LawContentTextView()
//                            LawLineView(law: vm.law, text: line.text, line: line.line, searchText: $searchText)
//                                .id(line.line)
//                        }
//                        Divider()
//                    }
//                }
//            }
//        }
    }
    
}
