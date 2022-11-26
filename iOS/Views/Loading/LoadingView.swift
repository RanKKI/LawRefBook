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
    
    @ViewBuilder
    var content: () -> Content
    
    var body: some View {
        if isLoading {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                Spacer()
            }
        } else {
            content()
        }
    }
    
}
