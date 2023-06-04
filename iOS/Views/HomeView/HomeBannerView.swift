//
//  HomeBannerView.swift
//  RefBook
//
//  Created by Hugh Liu on 19/3/2023.
//

import Foundation
import SwiftUI


struct HomeBannerView: View {
    
    
    @State
    var chatVM: ChatView.VM

    init() {
        self.chatVM = .init()
    }
    
    var body: some View {
        ZStack {
            NavigationLink {
                ChatView(vm: chatVM)
                    .navigationBarTitle("Chat", displayMode: .inline)
            } label: {
                Image("GPT_Banner")
                    .resizable(resizingMode: .stretch)
                    .scaledToFit()
            }
        }
        .modifier(HomeCardEffect())
        .padding([.leading, .trailing], 16)
    }
    
}

#if DEBUG
struct HomeBannerView_Preview: PreviewProvider {
    static var previews: some View {
        HomeBannerView()
    }
}
#endif
