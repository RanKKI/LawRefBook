import Foundation
import SwiftUI


private struct Change {
    var id: UUID = UUID()
    var icon: String
    var title: String
    var content: String

}

private var changes = [
    Change(icon: "doc", title: "增加复制功能", content: "长按法文可以选择复制"),
    Change(icon: "list.bullet.rectangle", title: "目录", content: "在可以用场景里，可以在右上角找到目录icon，点击即可查看法律目录。点击可以跳转到指定位置"),
    Change(icon: "list.number", title: "分组方式", content: "你可以在设置设置中设置分组方式，按法律部门或者阶位排序"),
]

struct WhatNewView : View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
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
                .padding(EdgeInsets(top: 48, leading: 8, bottom: 8, trailing: 8))
                .frame(width: 300, alignment: .leading)
            }
            Spacer()
            Button(action: {
                dismiss()
            }) {
                Text("好的")
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            }.buttonStyle(.borderedProminent)
        }
        .padding(EdgeInsets(top: 96, leading: 8, bottom: 32, trailing: 8))
        .interactiveDismissDisabled(true)
    }
}
