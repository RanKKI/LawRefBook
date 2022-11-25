import Foundation
import SwiftUI

class SheetMananger<T>: ObservableObject{

    @Published
    var isShowingSheet = false

    var state: T? = nil {
        didSet {
            isShowingSheet = state != nil
        }
    }
    
    func close() {
        state = nil
    }
}
