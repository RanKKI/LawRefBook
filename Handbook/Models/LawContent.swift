//
//  Config.swift
//  law.handbook
//
//  Created by Hugh Liu on 25/2/2022.
//

import Foundation

extension String {
    func addNewLine(str: String) -> String {
        return self + "\n   " + str
    }
}

class LawContent: ObservableObject {

    @Published var Titles: [String] = []
    @Published var Infomations: [LawInfo] = []
    @Published var Content: [TextContent] = []
    
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
        print("load", filename)
        if let filepath = Bundle.main.path(forResource: filename, ofType: "md", inDirectory: folder) {
            do {
                let contents = try String(contentsOfFile: filepath)
                DispatchQueue.main.async {
                    self.parse(contents:contents)
                    self.loaded = true
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("File not found")
        }
    }
    
    func parse(contents: String){
        let arr = contents.components(separatedBy: "\n").map{text in
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter{ line in
            return !line.isEmpty
        }
        
        var isDesc = true // 是否为信息部分
        var isFix = false // 是否为修正案
        
        for text in arr {
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
                self.Body.append(TextContent(text: out.count > 1 ? out[1] : "", children: []))
                continue
            }
            
            self.parseContent(&Body[Body.count - 1].children, text, isFix: isFix)
        }
        
        self.Content = Body
    }
    
    func parseContent(_ children: inout [String], _ text: String, isFix: Bool = false) {
        let matched = text.range(of: "^第.+条", options: .regularExpression) != nil
        
        if children.isEmpty || (isFix && !text.starts(with: "-")) || (!isFix && matched) {
            children.append(contentsOf: [text])
        } else {
            children[children.count - 1] = children.last!.addNewLine(str: text.trimmingCharacters(in: ["-"," "]))
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
                let children = val.children.filter { $0.contains(text) }
                newBody.append(TextContent(id: val.id, text: val.text, children: children))
            }
            self.Content = newBody
        }
    }
    
}
