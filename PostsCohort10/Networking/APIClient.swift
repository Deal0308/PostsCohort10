import Foundation

/// Shared HTTP client that validates responses and decodes JSON for all services.
struct APIClient {
    func fetch<T: Decodable>(from url: URL, as type: T.Type) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw APIError.requestFailed(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 429 {
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                .flatMap(TimeInterval.init)
            throw APIError.rateLimited(retryAfter: retryAfter)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.unsuccessfulStatusCode(httpResponse.statusCode)
        }

        guard !data.isEmpty else {
            throw APIError.emptyResponse
        }

        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw APIError.decodingFailed(error.localizedDescription)
        }
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case requestFailed(String)
    case invalidResponse
    case unsuccessfulStatusCode(Int)
    case decodingFailed(String)
    case invalidPostID
    case emptyResponse
    case rateLimited(retryAfter: TimeInterval?)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The API URL is not valid."
        case .requestFailed(let message):
            return "The request could not be completed. \(message)"
        case .invalidResponse:
            return "The server returned an invalid response."
        case .unsuccessfulStatusCode(let statusCode):
            return "The server returned status code \(statusCode)."
        case .decodingFailed(let message):
            return "The downloaded data could not be decoded. \(message)"
        case .invalidPostID:
            return "Enter a post number greater than zero."
        case .emptyResponse:
            return "The API returned no data."
        case .rateLimited(let retryAfter):
            if let retryAfter {
                return "Too many requests. Please wait about \(Int(retryAfter)) seconds before trying again."
            }

            return "Too many requests. Please wait a moment before trying again."
        }
    }
}
