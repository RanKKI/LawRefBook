//
//  SafariLink.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation
import SwiftUI

struct SafariLinkView: View {

    var title: String?
    var url: String

    @State
    private var showSafari = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if let title = title {
                    Text(title)
                    Text(url)
                        .font(.caption)
                } else {
                    Text(url)
                }
            }
            Spacer()
            Image(systemName: "arrow.turn.up.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showSafari.toggle()
        }
        .foregroundColor(.accentColor)
        .fullScreenCover(isPresented: $showSafari, content: {
            SFSafariViewWrapper(url: URL(string: url)!)
        })
    }

}
