//
//  VMCache.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation

class VMCache {
    
    static let shared = VMCache()
    
    private var cache = [String: LawList.SpecificCategoryViewModal]()
        
    // temp Fix
    // refactor needed
    func getModel(name: String) -> LawList.SpecificCategoryViewModal {
        if let vm = cache[name] {
            return vm
        }
        let vm = LawList.SpecificCategoryViewModal(category: name)
        cache[name] = vm
        return vm
    }
}
