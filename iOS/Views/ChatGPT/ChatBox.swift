//
//  ChatBox.swift
//  RefBook
//
//  Created by Hugh Liu on 16/7/2023.
//

import Foundation
import SwiftUI
import ActivityIndicatorView

struct ChatBoxView: View {
    
    let msg: ChatMessage
    var action: ((String) -> Void)? = nil

    private var maxWidth: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIScreen.main.bounds.width * 0.9
        } else {
            return UIScreen.main.bounds.width * 0.4
        }
    }
    
    private var minWidth: CGFloat {
        return maxWidth * 0.7
    }

    var body: some View {
        HStack {
            if msg.isBot {
                ChatBoxBotView(msg: msg)
                Spacer()
            } else {
                Spacer()
                ChatBoxBotView(msg: msg)
            }
        }
        .frame(minWidth: minWidth, maxWidth: maxWidth)
        .contentShape(Rectangle())
        .onTapGesture {
            if msg.isQuickAsk && msg.isBot {
                action?(msg.message)
            }
        }
    }
}

struct ChatBoxBotView: View {
    
    let msg: ChatMessage
    
    var body: some View {
        Group {
            if msg.isLoading {
                ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots(count: 3, inset: 10))
                    .frame(width: 50)
                    .foregroundColor(Color("ChatBoxBackgroundSelf"))
            } else if msg.isQuickAsk {
                Text("你可以问：") + Text(msg.message).underline()
            } else {
                Text(msg.message)
                    .textSelection(.enabled)
            }
        }
        .foregroundColor(msg.isBot ? Color("ChatBoxBackgroundBotText") : Color("ChatBoxBackgroundSelfText"))
        .padding([.leading, .trailing], 8)
        .padding([.top, .bottom], 16)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .cornerRadius(8, corners: [.topLeft, .topRight])
                .cornerRadius(8, corners: msg.isBot ? [.bottomRight] : [.bottomLeft])
                .foregroundColor(msg.isBot ? Color("ChatBoxBackgroundBot") : Color("ChatBoxBackgroundSelf"))
        )
    }
}

struct ChatBoxView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ChatBoxView(msg: .init(isBot: true, message: WARNING))
                ChatBoxView(msg: .init(isBot: true, message: "您可以问"))
                ChatBoxView(msg: .init(isBot: true, message: "您可以12321321312问"))
                ChatBoxView(msg: .init(isBot: true, message: "您可以问：虚假宣传相关的法律法规有哪些"))
                ChatBoxView(msg: .init(isBot: false, message: "您可以问：虚假宣传相关的法律法规有哪些"))
                ChatBoxView(msg: .init(isBot: false, message: "您可以问：些"))
                ChatBoxView(msg: .init(isBot: true, message: "", isLoading: true))
            }
            .padding(8)
        }
    }
}
