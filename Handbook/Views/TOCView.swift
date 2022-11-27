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
                ForEach(content.children, id: \.id){ sub in
                    TOCList(content: sub, action: action)
                }
            }
        }

    }
}

//struct TableOfContentView: View {
//
//    @ObservedObject
//    var vm: LawContentView.LawContentViewModel
//
//    @ObservedObject
//    var sheet: SheetMananger<LawContentView.SheetState>
//
//    var body: some View {
//        List(vm.content.TOC, id: \.id) { content in
//            TOCList(content: content) { line in
//                sheet.close()
//                vm.scrollPos = line
//            }
//        }
//        .listStyle(.plain)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing){
//                CloseSheetItem() {
//                    sheet.close()
//                }
//            }
//        }
//    }
//}
