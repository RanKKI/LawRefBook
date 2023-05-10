//
//  LoadingView.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation
import SwiftUI

struct LoadingView<Content: View>: View {

    @Binding
    var isLoading: Bool
    
    var message: String? = nil

    @ViewBuilder
    var content: () -> Content

    var body: some View {
        if isLoading {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        ProgressView()
                        if let message = message {
                            Text(message)
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
        } else {
            content()
        }
    }

}
