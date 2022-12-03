//
//  LawTOC.swift
//  RefBook
//
//  Created by Hugh Liu on 27/11/2022.
//

import Foundation

class LawToc: Identifiable {
    var id: Int64 { line }

    var title: String
    var indent: Int
    var line: Int64
    var children: [LawToc] = []
    
    init(title: String, indent: Int, line: Int64, children: [LawToc] = []) {
        self.title = title
        self.indent = indent
        self.line = line
        self.children = children
    }
}
