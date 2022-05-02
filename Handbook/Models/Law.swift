import Foundation
import SwiftUI

struct TextContent : Identifiable, Equatable {
    static func == (lhs: TextContent, rhs: TextContent) -> Bool {
        return lhs.id == rhs.id
    }
    

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

extension FavFolder {
    
    public var contents: [FavContent] {
        return content?.allObjects as! [FavContent]
    }

}
