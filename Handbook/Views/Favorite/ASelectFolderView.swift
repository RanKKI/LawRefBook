//import Foundation
//import SwiftUI
//
//struct SelectFolderView: View {
//
//    var folders: [FavFolder]
//    var onSelect: (FavFolder) -> Void
//
//    var body: some View {
//        List {
//            ForEach(folders, id: \.self) { (folder: FavFolder) in
//                HStack {
//                    Text(folder.name ?? "")
//                    Spacer()
//                }
//                .contentShape(Rectangle())
//                .onTapGesture {
//                    onSelect(folder)
//                }
//            }
//        }
//    }
//}
