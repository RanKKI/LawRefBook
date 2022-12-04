import Foundation
import SwiftUI

struct ShareLawEditView: View {

    @Binding
    var contents: [ShareLawView.ShareContent]

    var body: some View {
        List {
            ForEach(Array(contents.enumerated()), id: \.offset) { i, item in
                HStack(alignment: .top) {
                    CheckBoxView(isOn: contents[i].isSelected) { isOn in
                        contents[i].isSelected = isOn
                    }
                    Text(item.content)
                        .lineLimit(3)
                }
            }
        }
    }

}
