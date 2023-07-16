//
//  APIManager.swift
//  RefBook
//
//  Created by Hugh Liu on 2/3/2023.
//

import Foundation

enum APIError: Error {
    case invalidResponse
}

struct APIResponse: Codable {
    let message: String
}

final class APIManager {
    
    static let shard = APIManager()
    
    func chat(message: String) async throws -> String {
        guard let url = URL(string: "https://law.rankki.xyz/ai-law-ask") else {
            throw URLError(.badURL)
        }
        print("sending message: \(message)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let params = ["question": message, "id": Preference.shared.id]
        request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120
        print("\(request)")
        let response: URLResponse?
        let data: Data?
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            print("\(error.localizedDescription)")
            throw error
        }
        
        guard let data = data else {
            throw APIError.invalidResponse
        }
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        do {
            let resp = try decoder.decode(APIResponse.self, from: data)
            return resp.message.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            throw APIError.invalidResponse
        }
    }

}
