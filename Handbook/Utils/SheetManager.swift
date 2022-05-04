import Foundation
import SwiftUI

class SheetMananger<T>: ObservableObject{

    @Published
    var isShowingSheet = false

    @Published
    var state: T? = nil {
        didSet {
            withAnimation {
                isShowingSheet = state != nil
            }
        }
    }
    
    func close() {
        state = nil
    }
}
