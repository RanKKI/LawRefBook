//
//  WorkerLawListViewModel.swift
//  RefBook
//
//  Created by Hugh Liu on 10/5/2023.
//

import Foundation

extension WorkerLawListView {
    
    class VM: ObservableObject {
        
        @Published
        var isLoading = false
        
        @Published
        var categories = [TCategory]()
        
        func onAppear() {
            guard categories.isEmpty else { return }
            self.isLoading = true
            Task.init {
                var arr = [TCategory]()
                var laws = await LawManager.shared.getLaws(nameContains: "劳动")
                laws = laws.filter { $0.level != "案例" }
                let cases = await LawManager.shared.getLaws(category: "劳动人事")
                
                arr.append(contentsOf: [
                    TCategory.create(id: UUID(), level: "案例", laws: cases),
                    TCategory.create(id: UUID(), level: "相关法律", laws: laws)
                ])
                
                uiThread {
                    self.categories = arr
                    self.isLoading = false
                }
            }
        }
        
    }
    
}
