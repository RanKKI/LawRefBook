////
////  Config.swift
////  law.handbook
////
////  Created by Hugh Liu on 25/2/2022.
////
//
// import Foundation
//

//
// private class LawParser {
//    
//    private var forceBreak = false
//    var isCases = false
//    

//    
// }
//
// class ALawContent: ObservableObject {
//
//    var Titles: [String] = []
//    var Infomations: [LawInfo] = []
//    var Body: [TextContent] = []
//    var TOC: [LawToc] = []
//
//    private var filePath: String?
//    private var loaded: Bool = false
//    private var forceBreak: Bool = false
//    
//    private let parser = LawParser()
//    
//    @Published
//    var isLoading = false
//
//    init() {
//        self.filePath = nil
//    }
//    
//    init(filePath: String?, isCases: Bool) {
//        self.filePath = filePath
//        self.parser.isCases = isCases
//    }
//
//    func isExists() -> Bool {
//        return self.filePath != nil
//    }
//
//    private func fileData() -> String? {
//        if !self.isExists() {
//            return nil
//        }
//        if let filepath = self.filePath {
//            do {
//                return try String(contentsOfFile: filepath)
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//        }
//        return nil
//    }
//
//    func loadFromString(content: String) {
//        if loaded {
//            return
//        }
//        self.loaded = true
//        let (titles, desc, body, toc) = self.parser.parse(contents: content)
//        self.Titles = titles
//        self.Infomations = desc
//        self.Body = body
//        self.TOC = toc
//    }
//
//    func load() {
//        if loaded {
//            return
//        }
//        self.isLoading = true
//        if let content = self.fileData() {
//            self.loadFromString(content:content)
//            self.isLoading = false
//        }
//    }
//
//    func loadAsync() {
//        if loaded {
//            return
//        }
//        DispatchQueue.main.async {
//            self.load()
//        }
//    }
//
//    func filterText(text: String) -> [TextContent] {
//        if text.isEmpty {
//            return self.Body
//        }
//        let texts = text.tokenised()
//        var newBody: [TextContent] = []
//        self.Body.forEach { val in
//            let children = val.children.filter { child in
//                texts.allSatisfy { child.text.contains($0) }
//            }
//            if !children.isEmpty {
//                newBody.append(TextContent(id: val.id, text: val.text, children: children, line: val.line, indent: val.indent))
//            }
//        }
//        return newBody
//    }
//
//    func getLine(line: Int64) -> String {
//        for body in Body {
//            if body.line == line {
//                return body.text
//            }
//            for child in body.children {
//                if child.line == line {
//                    return child.text
//                }
//            }
//            if body.line > line {
//                break
//            }
//        }
//        return ""
//    }
//
//    func hasToc() -> Bool {
//        if self.TOC.isEmpty || self.TOC.count == 1{
//            return false
//        }
//        return true
//    }
//
// }
