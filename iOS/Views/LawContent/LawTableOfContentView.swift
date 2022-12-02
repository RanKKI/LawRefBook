import Foundation
import SwiftUI

struct TOCList: View {

    var content: LawToc

    var action: (Int64) -> Void

    @State
    private var isExpand = false

    var body: some View {
        if content.children.isEmpty {
            Text(content.title)
                .onTapGesture {
                    action(content.line)
                }
        } else {
            DisclosureGroup(content.title, isExpanded: $isExpand) {
                ForEach(content.children, id: \.id) { sub in
                    TOCList(content: sub, action: action)
                }
            }
        }

    }
}

struct LawTableOfContentView: View {

    var toc: [LawToc]
    
    var action: (Int64) -> Void
     
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
        List(toc, id: \.id) { content in
            TOCList(content: content) { line in
                dismiss()
                action(line)
            }
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
