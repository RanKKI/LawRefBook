//
//  LawContentView.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation
import SwiftUI

struct LawContentView: View {

    @ObservedObject
    private var vm: VM

    @ObservedObject
    private var sheets = SheetManager<Sheets>()

    @Environment(\.managedObjectContext)
    private var moc

    @State
    private var scroll: Int64?

    @State
    private var searchText = ""

    init(vm: VM) {
        self.vm = vm
    }

    var body: some View {
        LoadingView(isLoading: $vm.isLoading) {
            if let content = vm.content {
                LawContentDetailsView(law: vm.law, content: content, searchText: $searchText, scroll: $scroll)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if let content = vm.content, !content.toc.isEmpty {
                    IconButton(icon: "list.bullet.rectangle") {
                        sheets.state = .toc
                    }
                }
                IconButton(icon: vm.isFlagged ? "heart.slash" : "heart") {
                    vm.flag(moc)
                }
                IconButton(icon: "info.circle") {
                    sheets.state = .info
                }
            }
        }
        .sheet(isPresented: $sheets.isShowingSheet) {
            NavigationView {
                if let content = vm.content, sheets.state == .info {
                    LawInfoPage(lawID: vm.law.id, toc: content.info)
                        .navigationBarTitle("关于", displayMode: .inline)
                } else if let content = vm.content, sheets.state == .toc {
                    LawTableOfContentView(toc: content.toc) { line in
                        scroll = line
                    }
                    .navigationBarTitle("目录", displayMode: .inline)
                }
            }
            .phoneOnlyStackNavigationView()
        }
        .onAppear {
            vm.onAppear(moc: moc)
            searchText = vm.searchText
        }
        .searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onSubmit(of: .search) {
            searchText = vm.searchText
        }
        .onChange(of: vm.searchText) { text in
            if text.isEmpty {
                searchText = ""
            }
        }
    }

}

extension LawContentView {

    enum Sheets {
        case toc
        case info
    }

}
