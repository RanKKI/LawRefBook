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

extension FavFolder {
    
    public var contents: [FavContent] {
        return content?.allObjects as! [FavContent]
    }

}
