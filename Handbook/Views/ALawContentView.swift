//import Foundation
//import SwiftUI
//import SPAlert
//
//private struct LawLineView: View {
//
//    var law: TLaw
//
//    @State var text: String
//    @State var line: Int64
//    @State var showActions = false
//
//    @Binding
//    var searchText: String
//
//    @State
//    private var selectFolderView = false
//    
//    @State
//    private var shareT = false
//
//    @Environment(\.managedObjectContext)
//    private var moc
//
//    var body: some View {
//        Group {
//            LawContentLineView(text: text, searchText: $searchText)
//                .contextMenu {
//                    Button {
//                        selectFolderView.toggle()
//                    } label: {
//                        Label("收藏", systemImage: "suit.heart")
//                    }
//                    Button {
//                        Mail.reportIssue(law: law, content: text)
//                    } label: {
//                        Label("反馈", systemImage: "flag")
//                    }
//                    Button {
//                        let title = law.name
//                        let message = String(format: "%@\n\n%@", title, text)
//                        UIPasteboard.general.setValue(message, forPasteboardType: "public.plain-text")
//                    } label: {
//                        Label("复制", systemImage: "doc")
//                    }
////                    Button {
//
////                    } label: {
////                        Label("发送至", systemImage: "square.and.arrow.up")
////                    }
//                    Button {
//                        shareT.toggle()
//                    } label: {
//                        Label("分享", systemImage: "square.and.arrow.up")
//                    }
//                }
//        }
//        .sheet(isPresented: $selectFolderView) {
//            NavigationView {
//                FavoriteFolderView(action: { folder in
//                    if let folder = folder {
//                        FavContent.new(moc: moc, law.id, line: line, folder: folder)
//                        let alertView = SPAlertView(title: "添加成功", preset: .done)
//                        alertView.present(haptic: .success)
//                    }
//                })
//                .navigationViewStyle(.stack)
//                .navigationBarTitle("选择位置", displayMode: .inline)
//                .environment(\.managedObjectContext, moc)
//            }
//        }
//        .sheet(isPresented: $shareT) {
//            NavigationView {
//                ShareLawView(vm: .init([.init(name: law.name, content: text)]))
//                    .navigationBarTitleDisplayMode(.inline)
//                    .navigationTitle("分享")
//            }
//            .navigationViewStyle(.stack)
//        }
//    }
//}
