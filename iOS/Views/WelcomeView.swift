import Foundation
import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 48) {
            Text(COPYRIGHT_DECLARE)
        }
        .padding(.leading, 48)
        .padding(.trailing, 48)
    }
}
