import Foundation
import SwiftUI


private struct Change {
    var id: UUID = UUID()
    var icon: String
    var title: String
    var content: String

}

private var changes = [
    Change(icon: "heart", title: "收藏法条", content: "在法律法规内容界面，增加了收藏按钮。收藏后的法条法规将出现在主页列表最上面"),
    Change(icon: "textformat.size", title: "自定义文字大小", content: "在设置界面，可以设置法律法规内容的显示大小"),
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
