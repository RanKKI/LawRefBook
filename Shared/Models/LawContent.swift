//
//  LawContent.swift
//  RefBook
//
//  Created by Hugh Liu on 27/11/2022.
//

import Foundation

struct LawParagraph: Identifiable {
    var id: Int64 { line }
    var line: Int64
    var text: String
}

struct LawContentSection: Identifiable {
    var id: Int64 { line }
    var header: String
    var line: Int64
    var indent: Int
    var paragraphs: [LawParagraph] = []
}

struct LawContent {

    var titles: [String]
    var sections: [LawContentSection]
    var info: [LawInfo]
    var toc: [LawToc]

    func getLine(line: Int64) -> String? {
        for section in sections {
            if let text = section.paragraphs.first(where: { $0.line == line })?.text {
                return text
            }
            if section.line > line {
                break
            }
        }
        return nil
    }

}
