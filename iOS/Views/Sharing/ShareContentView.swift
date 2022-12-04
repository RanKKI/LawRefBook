//
//  ShareContentView.swift
//  RefBook
//
//  Created by Hugh Liu on 4/12/2022.
//

import Foundation
import SwiftUI

struct ShareContentView: View {
    
    var content: [[ShareLawView.ShareContent]]

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            ForEach(content, id: \.self) { section in
                Text(section.first?.name ?? "")
                    .font(.title2)
                    .padding([.bottom, .top], 8)
                    .multilineTextAlignment(.center)
                ForEach(section, id: \.self) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.content)
                            .padding([.trailing, .leading], 4)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            HStack {
                Spacer()
                Image(uiImage: generateQRCode(from: "https://apps.apple.com/app/apple-store/id1612953870"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
            }
        }
        .padding()
        .foregroundColor(.black)
        .snapView()
    }
    
}
