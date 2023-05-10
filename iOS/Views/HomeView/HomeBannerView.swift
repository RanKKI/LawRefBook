//
//  HomeBannerView.swift
//  RefBook
//
//  Created by Hugh Liu on 19/3/2023.
//

import Foundation
import SwiftUI


struct HomeBannerView: View {
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
        }
        .frame(height: 120)
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
