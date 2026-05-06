import Foundation

enum APIEndpoints {
    static let openAIBase = "https://api.openai.com/v1"
    static let chatCompletions = "/chat/completions"

    static func chatURL(apiKey: String) -> URL {
        URL(string: openAIBase + chatCompletions)!
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid URL"
        case .invalidResponse: "Invalid response from server"
        case .httpError(let code): "HTTP error: \(code)"
        case .decodingError: "Failed to decode response"
        case .networkUnavailable: "Network unavailable"
        }
    }
}

actor APIClient {
    func request<T: Decodable>(url: URL, method: String = "POST", headers: [String: String] = [:], body: Encodable? = nil) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        if let body {
            request.httpBody = try JSONEncoder().encode(body)
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    func rawRequest(url: URL, method: String = "POST", headers: [String: String] = [:], body: Data? = nil) async throws -> [String: Any] {
        var request = URLRequest(url: url)
        request.httpMethod = method
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        if let body {
            request.httpBody = body
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }
}
