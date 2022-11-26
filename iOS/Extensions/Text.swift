//
//  Text.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation
import SwiftUI

extension Text {
    
    enum DisplayMode {
        case Title // 内容标题

        // 子标题
        // 比如 第 n 章
        case Header
    }

    func center() -> some View {
        self.frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
    }

    
    func displayMode(_ mode: DisplayMode, indent: Int = 1) -> some View {
        switch(mode){
        case .Title:
            return self
                .center()
                .font(.title2)
                .padding([.bottom], 8)
        case .Header:
            return self
                .center()
                .font(indent == 1 ? .headline : .subheadline)
                .padding([.bottom], 8)
        }
    }

    func highlight(size: CGFloat) -> Text {
        self.font(.system(size: size)).bold().foregroundColor(Color.accentColor)
    }

}
