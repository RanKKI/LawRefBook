import Foundation
import SwiftUI

class Law: Codable {
    var name: String
    var id: UUID
    var level: String
    var filename: String?

    var cateogry: LawCategory?
}

class LawCategory: Codable {
    var category: String
    var laws: [Law]
    var id: UUID
    var folder: String?
}

struct TextContent : Identifiable {
    var id: UUID = UUID()
    var text: String
    var children: [String] = []
    var line: Int
    var indent: Int
}

class TocListData: Identifiable {
    var id: UUID = UUID()
    var children: [TocListData] = []
    var title: String
    var indent: Int
    var line: Int

    init(title: String, indent: Int, line: Int){
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
