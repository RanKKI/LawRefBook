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
    private var sheets = SheetMananger<Sheets>()

    init(vm: VM) {
        self.vm = vm
    }
    
    var body: some View {
        LoadingView(isLoading: $vm.isLoading) {
            if let law = vm.law, let content = vm.content {
                LawContentDetailsView(law: law, content: content, searchText: $vm.searchText)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                IconButton(icon: "list.bullet.rectangle") {
                    sheets.state = .toc
                }
                .transition(.opacity)
                IconButton(icon: true ? "heart.slash" : "heart") {
//                    vm.onFavIconClicked(moc: moc)
                }
                IconButton(icon: "info.circle") {
                    sheets.state = .info
                }
            }
        }
        .sheet(isPresented: $sheets.isShowingSheet) {
            NavigationView {
                if sheets.state == .info {
//                    LawInfoPage(lawID: vm.lawID, toc: vm.content.Infomations)
//                        .navigationBarTitle("关于", displayMode: .inline)
                } else if sheets.state == .toc {
//                    TableOfContentView(vm: vm, sheet: sheetManager)
//                        .navigationBarTitle("目录", displayMode: .inline)
                }
            }
            .phoneOnlyStackNavigationView()
        }
        .onAppear {
            vm.onAppear()
        }
        .searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .always))
    }

}


extension LawContentView {
    
    enum Sheets {
        case toc
        case info
    }
    
}
