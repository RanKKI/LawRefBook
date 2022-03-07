import Foundation
import SwiftUI

struct TOCList: View {

    var content: TocListData

    @Binding var sheetState: LawContentView.SheetMananger.SheetState
    @State private var isExpand = true
    @Binding var scrollID: Int?

    var body: some View {
        if content.children.isEmpty {
            Text(content.title)
                .onTapGesture {
                    sheetState = .none
                    scrollID = content.line
                }
        } else {
            DisclosureGroup(content.title, isExpanded: $isExpand) {
                ForEach(content.children, id: \.id){ sub in
                    TOCList(content: sub, sheetState: $sheetState, scrollID: $scrollID)
                }
            }
        }

    }
}

struct TableOfContentView: View {

    @ObservedObject var obj: LawContent
    @Binding var sheetState: LawContentView.SheetMananger.SheetState
    @Binding var scrollID: Int?

    var body: some View {
        List(obj.TOC, id: \.id) { content in
            TOCList(content: content, sheetState: $sheetState, scrollID: $scrollID)
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                CloseSheetItem() {
                    sheetState = .none
                }
            }
        }
    }
}
