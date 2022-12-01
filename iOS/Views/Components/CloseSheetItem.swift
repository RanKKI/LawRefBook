import Foundation
import SwiftUI

struct CloseSheetItem : View {

    var action: () -> Void = {}

    var body: some View {
        Button(action: action, label: {
            Text("关闭")
                .foregroundColor(.red)
        })
    }

}
