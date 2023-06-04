//
//  ChatMessage.swift
//  RefBook
//
//  Created by Hugh Liu on 2/3/2023.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    var id: UUID = .init()
    var isError = false
    var isBot: Bool
    var message: String
}
