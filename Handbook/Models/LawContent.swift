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

class LawContent: ObservableObject {

    @Published var Titles: [String] = []
    @Published var Infomations: [LawInfo] = []
    @Published var Content: [TextContent] = []
    @Published var TOC: [TocListData] = []

    var Body: [TextContent] = []
    var filename: String
    var folder: String

    private var loaded: Bool = false

    init(_ filename: String, _ folder: String){
        self.filename = filename
        self.folder = folder
    }

    func load(){
        if loaded {
            return
        }
        self.loaded = true
        print("load", folder, filename)
        if let filepath = Bundle.main.path(forResource: filename, ofType: "md", inDirectory: folder) {
            do {
                let contents = try String(contentsOfFile: filepath)
                DispatchQueue.main.async {
                    self.parse(contents:contents)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("File not found")
        }
    }

    func parse(contents: String){
        var isDesc = true // 是否为信息部分
        var isFix = false // 是否为修正案

        for (no, line) in contents.components(separatedBy: "\n").enumerated() {

            let text = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if text.isEmpty {
                continue
            }

            let out = text.split(separator: " ", maxSplits: 1).map { String($0) }
            if out.isEmpty {
                continue
            }

            if out[0] == "#" { // 标题
                Titles.append(out[1])
                isFix = isFix || text.contains("修正")
                continue
            }

            if text.starts(with: "<!-- INFO END -->") { // 信息部分结束
                isDesc = false
                continue
            }

            if isDesc {
                if out.count > 1 {
                    Infomations.append(LawInfo(header: out[0], content: out[1]))
                } else {
                    Infomations.append(LawInfo(header: "", content: text))
                }
                continue
            }

            if out[0].hasPrefix("#") { // 标题
                let indent = out[0].count - 1
                let title = out.count > 1 ? out[1] : ""
                if indent == 1 || self.TOC.isEmpty {
                    self.TOC.append(TocListData(title: title, indent: indent, line: no))
                } else {
                    var i = indent
                    var targetToc: TocListData = self.TOC.last!
                    while i - 1 > targetToc.indent && !targetToc.children.isEmpty {
                        targetToc = targetToc.children.last!
                        i -= 1
                    }
                    targetToc.children.append(TocListData(title: title, indent: indent, line: no))
                }
                self.Body.append(TextContent(text: title, line: no, indent: indent))
                continue
            }

            if self.Body.isEmpty {
                self.Body.append(TextContent(text: "", line: no, indent: 1))
            }

            self.parseContent(&Body[Body.count - 1].children, text, isFix: isFix, no: no)
        }

        self.Content = Body
    }

    func parseContent(_ children: inout [TextContent.Content], _ text: String, isFix: Bool, no: Int) {
        if children.isEmpty || (isFix && !text.starts(with: "-")) || (!isFix && text.range(of: "^第.+?条", options: .regularExpression) != nil ){
//            children.append(text)
            children.append(TextContent.Content(no, text))
        } else {
            let newLine = text.trimmingCharacters(in: ["-"," "])
            if newLine.count > 100 {
                children[children.count - 1].text = children[children.count - 1].text.addNewLine(str: "")
            }
            children[children.count - 1].text = children[children.count - 1].text.addNewLine(str: newLine)
    
        }
    }

    func filterText(text: String){
        if text.isEmpty {
            self.Content = self.Body
            return
        }
        DispatchQueue.main.async {
            var newBody: [TextContent] = []
            self.Body.forEach { val in
                let children = val.children.filter { $0.text.contains(text) }
                newBody.append(TextContent(id: val.id, text: val.text, children: children, line: val.line, indent: val.indent))
            }
            self.Content = newBody
        }
    }

    func hasToc() -> Bool {
        if self.TOC.isEmpty || self.TOC.count == 1{
            return false
        }
        return true
    }

}
