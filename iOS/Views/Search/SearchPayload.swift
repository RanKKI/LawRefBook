//
//  SearchPayload.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation

final class SearchPayload: ObservableObject {
    
    @Published
    var text = ""
    
    @Published
    private(set) var submit = false
    
    func onSubmit() {
        submit = true
    }
    
    func afterSubmit() {
        submit = false
    }
}
