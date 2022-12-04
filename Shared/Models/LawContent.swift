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

class LawContentSection: Identifiable, ObservableObject {
    var id: Int64 { line }
    var header: String
    var line: Int64
    var indent: Int
    var paragraphs: [LawParagraph] = []

    init(header: String, line: Int64, indent: Int, paragraphs: [LawParagraph] = []) {
        self.header = header
        self.line = line
        self.indent = indent
        self.paragraphs = paragraphs
    }

    init(section: LawContentSection, paragraphs: [LawParagraph] = []) {
        self.header = section.header
        self.line = section.line
        self.indent = section.indent
        self.paragraphs = paragraphs
    }

}

class LawContent: ObservableObject {

    var titles: [String]
    var rawSections: [LawContentSection]
    var info: [LawInfo]
    var toc: [LawToc]

    @Published
    var sections: [LawContentSection] = []

    init(titles: [String], sections: [LawContentSection], info: [LawInfo], toc: [LawToc]) {
        self.titles = titles
        self.rawSections = sections
        self.sections = sections
        self.info = info
        self.toc = toc
    }

    func getLine(line: Int64) -> String? {
        for section in sections {
            if section.line == line {
                return section.header
            }
            if let text = section.paragraphs.first(where: { $0.line == line })?.text {
                return text
            }
            if section.line > line {
                break
            }
        }
        return nil
    }

    func hasText(text: String) async -> Bool {
        let texts = text.tokenised()
        for section in sections {
            if section.header.contains(text) || texts.allSatisfy({ section.header.contains($0) }) {
                return true
            }
            for paragraph in section.paragraphs {
                if paragraph.text.contains(text) || texts.allSatisfy({ paragraph.text.contains($0) }) {
                    return true
                }
            }
        }
        return false
    }

    func filter(text: String) {
        if text.trimmingCharacters(in: .whitespaces).isEmpty {
            self.sections = rawSections
            return
        }
        Task {
            var result = [LawContentSection]()
            let texts = text.tokenised()
            for section in sections {
                let paragraphs = section.paragraphs.filter { paragraph in
                    paragraph.text.contains(text) || texts.allSatisfy({ paragraph.text.contains($0) })
                }
                if !paragraphs.isEmpty {
                    result.append(.init(section: section, paragraphs: paragraphs))
                }
            }
            uiThread {
                self.sections = result
            }
        }
    }

}
