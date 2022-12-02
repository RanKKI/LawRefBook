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
    private(set) var isSubmit = false

    func submit() {
        isSubmit = true
    }

    func submit(text: String) {
        self.text = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.submit()
        }
    }

    func afterSubmit() {
        isSubmit = false
    }
}
