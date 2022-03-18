import Foundation
import SwiftUI


private struct Change {
    var id: UUID = UUID()
    var icon: String
    var title: String
    var content: String

}

private var changes = [
    Change(icon: "magnifyingglass", title: "Spotlight 索引", content: "你可以在设置中创建 Spotlight 索引，方便以后查找法律。（Spotlight即下拉搜索）"),
]

struct WhatNewView : View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 36) {
            Text("看看有什么更新!")
                .font(.largeTitle)
            ForEach(changes, id: \.id) { change in
                HStack(spacing: 16) {
                    Image(systemName: change.icon)
                        .font(.system(size: 36))
                        .frame(maxWidth: 60)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(change.title)
                            .font(.title2)
                            .bold()
                        Text(change.content)
                    }
                }
                .frame(width: 280, alignment: .leading)
            }
            Spacer()
            Button(action: {
                dismiss()
            }) {
                Text("好的")
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(EdgeInsets(top: 96, leading: 8, bottom: 32, trailing: 8))
        .interactiveDismissDisabled(true)
    }
}
