//
//  Config.swift
//  law.handbook
//
//  Created by Hugh Liu on 25/2/2022.
//

import Foundation

class LawModel: ObservableObject {
    
    @Published var Titles: [String] = []
    @Published var Desc: [Info] = []
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
            let out = text.split(separator: " ", maxSplits: 1)
            if out.isEmpty {
                continue
            }
            
            if out[0] == "#" { // 标题
                Titles.append(String(out[1]))
                isFix = isFix || text.contains("修正")
                continue
            }
            
            if text.starts(with: "<!-- INFO END -->") { // 信息部分结束
                isDesc = false
                continue
            }
            
            if isDesc {
                var info = Info(header: out[0])
                if out.count > 1 {
                    info.content = out[1]
                }
                self.Desc.append(info)
                continue
            }
            
            if out[0].hasPrefix("#") { // 标题
                self.Body.append(TextContent(text: out.count > 1 ? String(out[1]) : "", children: []))
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
    
}

class Law: Hashable {
    
    var name: String
    var folder: String?
    var file: String?
    
    private var modal: LawModel? = nil
    
    init(name: String,folder: String? = nil,file: String? = nil){
        self.name = name
        self.folder = folder
        self.file = file
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    func getModal() -> LawModel {
        if modal == nil {
            modal = LawModel(file ?? name, folder == nil ? "法律法规" : "法律法规/" + folder!)
        }
        return modal!
    }
    
    static func == (lhs: Law, rhs: Law) -> Bool {
        return lhs.name == rhs.name && lhs.folder == rhs.folder && lhs.file == rhs.file
    }
    
}

struct LawGroup : Hashable{
    var name: String
    var laws: [Law]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

struct TextContent : Identifiable {
    var id: UUID = UUID()
    var text: String
    var children: [String]
}

struct Info: Identifiable {
    var id: UUID = UUID()
    var header: Substring
    var content: Substring = ""
}

extension String {
    func addNewLine(str: String) -> String {
        return self + "\n   " + str
    }
}
