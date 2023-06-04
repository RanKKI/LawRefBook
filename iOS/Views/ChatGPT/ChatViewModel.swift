//
//  ChatViewModel.swift
//  RefBook
//
//  Created by Hugh Liu on 2/3/2023.
//

import Foundation

extension ChatView {

    class VM: ObservableObject {
        
        @Published
        var messages: [ChatMessage] = .init()
        
        @Published
        var isLoading = false
        
        @Published
        var newMsg = false
        
        init() {
            if Preference.shared.chatCount <= 0 {
                Preference.shared.chatCount = 5
            }
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
                    uiThread {
                        self.messages.append(.init(isBot: true, message: result))
                        self.isLoading = false
                    }
                } catch {
                    uiThread {
                        self.messages.append(.init(isError: true, isBot: true, message: error.localizedDescription))
                        self.isLoading = false
                    }
                }
            }
        }
        
    }
    
}
