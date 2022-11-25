//
//  Laws.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation
import SQLite

final class LawManager: ObservableObject {
    
    static let shared = LawManager()
    
    @Published
    private(set) var isLoading = false

    private var connections = [Connection]()
    
    func connect() async {
        uiThread {
            self.isLoading = true
        }
        do {
            connections = try LocalManager.shared.getDatabaseFiles()
                .map { try Connection($0.absoluteString) }
        } catch {
            fatalError("unable to connect all sqlite file")
        }
        uiThread {
            self.isLoading = false
        }
    }

}
