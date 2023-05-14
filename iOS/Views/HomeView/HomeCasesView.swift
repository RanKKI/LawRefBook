//
//  HomeCasesView.swift
//  RefBook
//
//  Created by Hugh Liu on 19/3/2023.
//

import Foundation
import SwiftUI

struct HomeCasesView: View {

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("经典案例")
                    .bold()
                    .font(.system(size: 14))
                Spacer()
                NavigationLink {
                    CasesView.ListType(vm: .init())
                        .navigationTitle("经典案例")
                } label: {
                    ViewAllCaseButton()
                }
            }
            CasesView(vm: .init(limit: 10))
        }
        .padding([.leading, .trailing], 16)
    }
}

private struct ViewAllCaseButton: View {
    
    var body: some View {
        HStack(spacing: 4) {
            Text("查看全部")
                .foregroundColor(.gray)
                .font(.caption)
            Image(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundColor(.gray)
        }
    }
    
}

#if DEBUG
struct HomeCasesView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCasesView()
    }
}
#endif
