//
//  LawListContentView.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation
import SwiftUI


struct WorkerLawListView: View {
    
    @State
    var vm: WorkerLawListView.VM
    
    init() {
        self.vm = .init()
    }
    
    var body: some View {
        LoadingView(isLoading: $vm.isLoading) {
            _WorkerLawListView(vm: vm)
        }
        .onAppear {
            vm.onAppear()
        }
    }
    
}

private struct _WorkerLawListView: View {

    @ObservedObject
    var vm: WorkerLawListView.VM

    var body: some View {
        List {
            ForEach(vm.categories, id: \.self) { cateogry in
                LawListCategorySectionView(label: cateogry.name) {
                    LawListCategoryView(category: cateogry, showAll: true)
                }
            }
        }
    }

}
