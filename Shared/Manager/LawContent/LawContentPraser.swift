//
//  LawContentPraser.swift
//  RefBook
//
//  Created by Hugh Liu on 27/11/2022.
//

import Foundation

class LawContentParser {

    static let shared = LawContentParser()

    private var forceBreak = false
    private var isCases = false

    func parse(data: Data) -> LawContent? {
        guard let contents = String(data: data, encoding: .utf8) else {
            return nil
        }
        let (titles, infos, sections, toc) = self.parse(contents: contents)
        return LawContent(titles: titles, sections: sections, info: infos, toc: toc)
    }

    func parse(contents: String) -> ([String], [LawInfo], [LawContentSection], [LawToc]) {
        var isDesc = true // 是否为信息部分
        var isFix = false // 是否为修正案
        var noOfLine: Int64 = 0
        var isTable = false

        var titleArr = [String]()
        var bodyArr = [LawContentSection]()
        var info = [LawInfo]()
        var toc = [LawToc]()

        for line in contents.components(separatedBy: "\n") {
            let text = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if text.isEmpty {
                continue
            }

            let out = text.split(separator: " ", maxSplits: 1).map { String($0) }

            if out.isEmpty {
                continue
            }

            if out[0] == "#" { // 标题
                titleArr.append(out[1])
                isFix = isFix || text.contains("修正")
                continue
            }

            if text.starts(with: "<!-- INFO END -->") { // 信息部分结束
                isDesc = false
                continue
            }

            if text.starts(with: "<!-- FORCE BREAK -->") {
                self.forceBreak = true
                continue
            }

            var isNewLine = self.isNewLine(text: text, isFix: isFix)

            if text.starts(with: "<!-- TABLE -->") {
                isTable = true
                isNewLine = true
            }

            if isTable {

            }

            if text.starts(with: "<!-- TABLE END -->") {
                isTable = false
                continue
            }

            if isDesc {
                if out.count > 1 {
                    info.append(LawInfo(header: out[0], content: out[1]))
                } else {
                    info.append(LawInfo(header: "", content: text))
                }
                continue
            }

            if out[0].hasPrefix("#") { // 标题
                let indent = out[0].count - 1
                let title = out.count > 1 ? out[1] : ""
                if indent == 1 || toc.isEmpty {
                    toc.append(LawToc(title: title, indent: indent, line: noOfLine))
                } else {
                    var i = indent
                    var targetToc = toc.last!
                    while i - 1 > targetToc.indent && !targetToc.children.isEmpty {
                        targetToc = targetToc.children.last!
                        i -= 1
                    }
                    targetToc.children.append(LawToc(title: title, indent: indent, line: noOfLine))
                }

                bodyArr.append(LawContentSection(header: title, line: noOfLine, indent: indent))
                noOfLine += 1
                continue
            }

            if bodyArr.isEmpty {
                bodyArr.append(LawContentSection(header: "", line: noOfLine, indent: 1))
                noOfLine += 1
            }

            let newLine = self.parseContent(&bodyArr[bodyArr.count - 1].paragraphs, text, isFix: isFix, no: noOfLine, newLine: isNewLine)

            if newLine {
                noOfLine += 1
            }
        }

        return (titleArr, info, bodyArr, toc)
    }

    func isNewLine(text: String, isFix: Bool) -> Bool {
        if self.forceBreak {
            self.forceBreak = false
            return true
        }
        if self.isCases {
            return true
        }
        return (isFix && !text.starts(with: "-")) || (!isFix && text.range(of: lineStartRe, options: .regularExpression) != nil)
    }

    func parseContent(_ children: inout [LawParagraph], _ text: String, isFix: Bool, no: Int64, newLine: Bool) -> Bool {
        if children.isEmpty || newLine {
            children.append(LawParagraph(line: no, text: text))
            return true
        }
        let newLine = text.trimmingCharacters(in: ["-", " "])
        if newLine.count > 100 {
            children[children.count - 1].text = children[children.count - 1].text.addNewLine(str: "")
        }
        children[children.count - 1].text = children[children.count - 1].text.addNewLine(str: newLine)
        return false
    }

}
