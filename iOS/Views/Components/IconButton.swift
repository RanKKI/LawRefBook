import Foundation
import SwiftUI

struct IconButton: View {
    var icon: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action, label: {
            Image(systemName: icon)
                .foregroundColor(.red)
        })
    }
}
