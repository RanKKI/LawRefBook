import Foundation
import SwiftUI

class Law: Codable {
    var name: String
    var id: UUID
    var level: String
    var filename: String?

    var links: [UUID]?
    var cateogry: LawCategory?
}

class LawCategory: Codable {
    var category: String
    var laws: [Law]
    var id: UUID
    var folder: String?

    var links: [UUID]? // 该目录下所有法律都会继承这个
}

struct TextContent : Identifiable {

    class Content: Identifiable{
        var id: UUID = UUID()
        var line: Int64
        var text: String

        init(_ line: Int64, _ text: String) {
            self.line = line
            self.text = text
        }
    }

    var id: UUID = UUID()
    var text: String
    var children: [Content] = []
    var line: Int64
    var indent: Int
}

class TocListData: Identifiable {
    var id: UUID = UUID()
    var children: [TocListData] = []
    var title: String
    var indent: Int
    var line: Int64

    init(title: String, indent: Int, line: Int64){
        self.title = title
        self.indent = indent
        self.line = line
    }
}

struct LawInfo {
    var id: UUID = UUID()
    var header: String
    var content: String
}


enum LawGroupingMethod: String, CaseIterable {
    case department = "法律部门"
    case level = "法律阶位"
}
