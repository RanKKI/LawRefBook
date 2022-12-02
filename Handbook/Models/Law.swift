import Foundation
import SwiftUI

extension FavFolder {
    
    public var contents: [FavContent] {
        return content?.allObjects as? [FavContent] ?? []
    }

}
