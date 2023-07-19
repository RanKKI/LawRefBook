//
//  ChatMessage.swift
//  RefBook
//
//  Created by Hugh Liu on 2/3/2023.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    var id: UUID = .init()
    var isBot: Bool
    var message: String
    var isLoading = false
    var isError = false
    var isQuickAsk = false
}
