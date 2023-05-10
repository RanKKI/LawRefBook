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
            VStack(spacing: 16) {
                Spacer()
                ProgressView()
                if let message = message {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
        } else {
            content()
        }
    }

}

#if DEBUG
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(isLoading: .constant(true)) {
            EmptyView()
        }
        LoadingView(isLoading: .constant(true), message: "加载中") {
            EmptyView()
        }
    }
}
#endif
