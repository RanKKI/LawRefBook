//
//  Config.swift
//  law.handbook
//
//  Created by Hugh Liu on 25/2/2022.
//

import Foundation

extension String {
    func addNewLine(str: String) -> String {
        return self + "\n" + str
    }
}

private class LawParser {
    
    private var forceBreak = false
    var isCases = false
    
    func parse(contents: String) -> ([String], [LawInfo], [TextContent], [TocListData]) {
        var isDesc = true // 是否为信息部分
        var isFix = false // 是否为修正案
        var noOfLine: Int64 = 0
        
        var titleArr = [String]()
        var bodyArr = [TextContent]()
        var info = [LawInfo]()
        var toc = [TocListData]()

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
                    toc.append(TocListData(title: title, indent: indent, line: noOfLine))
                } else {
                    var i = indent
                    var targetToc: TocListData = toc.last!
                    while i - 1 > targetToc.indent && !targetToc.children.isEmpty {
                        targetToc = targetToc.children.last!
                        i -= 1
                    }
                    targetToc.children.append(TocListData(title: title, indent: indent, line: noOfLine))
                }
                bodyArr.append(TextContent(text: title, line: noOfLine, indent: indent))
                noOfLine += 1;
                continue
            }

            if bodyArr.isEmpty {
                bodyArr.append(TextContent(text: "", line: noOfLine, indent: 1))
                noOfLine += 1;
            }

            let newLine = self.parseContent(&bodyArr[bodyArr.count - 1].children, text, isFix: isFix, no: noOfLine)

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

    func parseContent(_ children: inout [TextContent.Content], _ text: String, isFix: Bool, no: Int64) -> Bool {
        if children.isEmpty || isNewLine(text: text, isFix: isFix) {
            children.append(TextContent.Content(no, text))
            return true
        }
        let newLine = text.trimmingCharacters(in: ["-"," "])
        if newLine.count > 100 {
            children[children.count - 1].text = children[children.count - 1].text.addNewLine(str: "")
        }
        children[children.count - 1].text = children[children.count - 1].text.addNewLine(str: newLine)
        return false
    }
    
}

class LawContent: ObservableObject {

    var Titles: [String] = []
    var Infomations: [LawInfo] = []
    var Body: [TextContent] = []
    var TOC: [TocListData] = []

    private var filePath: String?
    private var loaded: Bool = false
    private var forceBreak: Bool = false
    
    private let parser = LawParser()
    
    @Published
    var isLoading = false

    init() {
        self.filePath = nil
    }
    
    init(filePath: String?, isCases: Bool) {
        self.filePath = filePath
        self.parser.isCases = isCases
    }

    func isExists() -> Bool {
        return self.filePath != nil
    }

    private func fileData() -> String? {
        if !self.isExists() {
            return nil
        }
        if let filepath = self.filePath {
            do {
                return try String(contentsOfFile: filepath)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    func loadFromString(content: String) {
        if loaded {
            return
        }
        self.loaded = true
        let (titles, desc, body, toc) = self.parser.parse(contents: content)
        self.Titles = titles
        self.Infomations = desc
        self.Body = body
        self.TOC = toc
    }

    func load() {
        if loaded {
            return
        }
        self.isLoading = true
        if let content = self.fileData() {
            self.loadFromString(content:content)
            self.isLoading = false
        }
    }

    func loadAsync() {
        if loaded {
            return
        }
        DispatchQueue.main.async {
            self.load()
        }
    }

    func filterText(text: String) -> [TextContent] {
        if text.isEmpty {
            return self.Body
        }
        let texts = text.tokenised()
        var newBody: [TextContent] = []
        self.Body.forEach { val in
            let children = val.children.filter { child in
                texts.allSatisfy { child.text.contains($0) }
            }
            if !children.isEmpty {
                newBody.append(TextContent(id: val.id, text: val.text, children: children, line: val.line, indent: val.indent))
            }
        }
        return newBody
    }

    func getLine(line: Int64) -> String {
        for body in Body {
            if body.line == line {
                return body.text
            }
            for child in body.children {
                if child.line == line {
                    return child.text
                }
            }
            if body.line > line {
                break
            }
        }
        return ""
    }

    func hasToc() -> Bool {
        if self.TOC.isEmpty || self.TOC.count == 1{
            return false
        }
        return true
    }

}
