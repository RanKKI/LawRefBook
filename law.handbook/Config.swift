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

let DeveloperMail = "rankki.dev@icloud.com"

var laws: [LawGroup] = [
    LawGroup(name: "宪法及宪法相关法", laws: [
        Law(name: "宪法"),
        Law(name: "国籍法"),
        Law(name: "身份证法"),
    ]),
    LawGroup(name: "民法商法", laws: [
        Law(name: "消费者权益保护法"),
        Law(name: "个人信息保护法"),
        Law(name: "著作权法"),
    ]),
    LawGroup(name: "行政法", laws: [
        Law(name: "食品安全法"),
        Law(name: "广告法"),
        Law(name: "人民警察法"),
    ]),
    LawGroup(name: "社会法", laws: [
        Law(name: "劳动法"),
        Law(name: "劳动合同法"),
    ]),
    LawGroup(name: "诉讼与非诉讼程序法", laws: [
        Law(name: "民事诉讼法"),
    ]),
    LawGroup(name: "刑法及刑法修正案", laws: [
        Law(name: "刑法"),
        Law(name: "刑法修正案（一）", folder: "刑法修正案", file: "1"),
        Law(name: "刑法修正案（二）", folder: "刑法修正案", file: "2"),
        Law(name: "刑法修正案（三）", folder: "刑法修正案", file: "3"),
        Law(name: "刑法修正案（四）", folder: "刑法修正案", file: "4"),
        Law(name: "刑法修正案（五）", folder: "刑法修正案", file: "5"),
        Law(name: "刑法修正案（六）", folder: "刑法修正案", file: "6"),
        Law(name: "刑法修正案（七）", folder: "刑法修正案", file: "7"),
        Law(name: "刑法修正案（八）", folder: "刑法修正案", file: "8"),
        Law(name: "刑法修正案（九）", folder: "刑法修正案", file: "9"),
        Law(name: "刑法修正案（十）", folder: "刑法修正案", file: "10"),
        Law(name: "刑法修正案（十一）", folder: "刑法修正案", file: "11"),
    ]),
    LawGroup(name: "民法典", laws: [
        Law(name: "总则", folder: "民法典"),
        Law(name: "物权", folder: "民法典"),
        Law(name: "合同", folder: "民法典"),
        Law(name: "人格权", folder: "民法典"),
        Law(name: "婚姻家庭", folder: "民法典"),
        Law(name: "继承", folder: "民法典"),
        Law(name: "侵权责任", folder: "民法典"),
        Law(name: "附则", folder: "民法典"),
    ]),
    LawGroup(name: "宪法修正案", laws: [
        Law(name: "宪法修正案（1988年）", folder:"宪法修正案", file: "1988年"),
        Law(name: "宪法修正案（1993年）", folder:"宪法修正案", file: "1993年"),
        Law(name: "宪法修正案（1999年）", folder:"宪法修正案", file: "1999年"),
        Law(name: "宪法修正案（2004年）", folder:"宪法修正案", file: "2004年"),
        Law(name: "宪法修正案（2018年）", folder:"宪法修正案", file: "2018年"),
    ]),
    LawGroup(name: "司法解释", laws: [
        Law(name: "最高人民法院关于适用《中华人民共和国民事诉讼法》的解释", folder: "司法解释", file: "民事诉讼法"),
    ]),
    LawGroup(name: "规定", laws: [
        Law(name: "工资支付暂行规定", folder: "暂行规定", file: "工资支付"),
    ]),
    LawGroup(name: "办法", laws: [
        Law(name: "国家机关、事业单位贯彻<国务院关于职工工作时间的规定>  的实施办法", folder: "办法"),
    ]),
]
