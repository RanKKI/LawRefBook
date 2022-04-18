import Foundation
import SwiftUI


private struct Change {
    var id: UUID = UUID()
    var icon: String
    var title: String
    var content: String

}

private var changes = [
    Change(icon: "icloud", title: "iCloud 同步", content: "设置中打开 iCloud 同步，将收藏的内容跨设备使用（注：打开后需要重启 App 并给予网络相关的权限）"),
    Change(icon: "doc.text.magnifyingglass", title: "搜索历史", content: "搜索记录现会被保存本地，你可在设置中调整是独立记录（即每个法律不共享搜索记录）或者共享记录（注：搜索记录仅保留在本地，不使用 iCloud 同步）"),
]

struct WhatNewView : View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 36) {
            Text("看看有什么更新！")
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
