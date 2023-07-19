//
//  ChatViewModel.swift
//  RefBook
//
//  Created by Hugh Liu on 2/3/2023.
//

import Foundation

let WARNING = """
您应知晓您发送的内容将发送至开发者 的服务器，您的内容可能会被加入进模型进行训练，因此，请勿输入任何涉密、私人信息。

任何回复不构成法律建议，如您真的需要法律帮助，找律师。
"""
let WARNING2 = """
AI法律助手可以根据你的问题提供简单的法律咨询服务、法律概念解析等
"""

extension ChatView {

    class VM: ObservableObject {
        
        @Published
        var messages: [ChatMessage] = [
            .init(isBot: true, message: WARNING),
            .init(isBot: true, message: WARNING2),
            .init(isBot: true, message: "老板让加班不给加班费怎么办？", isQuickAsk: true),
            .init(isBot: true, message: "什么是虚假宣传？", isQuickAsk: true),
        ]

        @Published
        var isLoading = false

        init() {

        }
        
        func submit(text: String) {
            if self.isLoading {
                return
            }
            Task {
                uiThread {
                    self.messages.append(.init(isBot: false, message: text))
                    self.isLoading = true
                }
                do {
                    let result = try await APIManager.shard.chat(message: text)
//                    let result = """
//123213
//312
//3
//213
//12
//32
//13
//12
//3
//12
//"""
//                    try await Task.sleep(nanoseconds: UInt64(3 * Double(NSEC_PER_SEC)))
                    uiThread {
                        self.messages.append(.init(isBot: true, message: result))
                        self.isLoading = false
                    }
                } catch {
                    print(error)
                    uiThread {
                        self.messages.append(.init(isBot: true, message: error.localizedDescription, isError: true))
                        self.isLoading = false
                    }
                }
            }
        }
        
    }
    
}
