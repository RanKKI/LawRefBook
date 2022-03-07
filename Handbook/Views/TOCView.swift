import Foundation
import SwiftUI

struct TOCList: View {
    var content: TocListData

    @State private var isExpand = true

    var body: some View {
        if content.children.isEmpty {
            Text(content.title)
        } else {
            DisclosureGroup(content.title, isExpanded: $isExpand) {
                ForEach(content.children, id: \.id){ sub in
                    TOCList(content: sub)
                }
            }
        }

    }
}

struct TableOfContentView: View {

    @ObservedObject var obj: LawContent
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List(obj.TOC, id: \.id) { content in
            TOCList(content: content)
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                CloseSheetItem() {
                    dismiss()
                }
            }
        }
    }
}
