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
        guard let url = URL(string: "https://01ratzfwj6.execute-api.ap-southeast-1.amazonaws.com/ask") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let params = ["question": message, "id": Preference.shared.id]
        request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.data(for: request)
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
