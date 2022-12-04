//
//  ShareButton.swift
//  RefBook
//
//  Created by Hugh Liu on 1/12/2022.
//

import Foundation
import SwiftUI

struct ShareButton: View {

    @Binding
    var sharing: Bool

    var body: some View {
        Button {
            sharing.toggle()
        } label: {
            Label("分享", systemImage: "square.and.arrow.up")
        }
    }

}
