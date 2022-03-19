import Foundation
import SwiftUI

struct CloseSheetItem : View {

    var action: () -> Void = {}

    var body: some View {
        IconButton(icon: "xmark.circle", action: action)
    }

}
