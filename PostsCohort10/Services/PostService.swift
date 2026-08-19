import Foundation

/// Handles JSONPlaceholder post endpoints.
struct PostService {
    private let endpoint = "https://jsonplaceholder.typicode.com/posts"
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchPosts() async throws -> [Post] {
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }

        return try await apiClient.fetch(from: url, as: [Post].self)
    }

    func fetchPost(id: Int) async throws -> Post {
        guard id > 0 else {
            throw APIError.invalidPostID
        }

        guard let url = URL(string: "\(endpoint)/\(id)") else {
            throw APIError.invalidURL
        }

        return try await apiClient.fetch(from: url, as: Post.self)
    }
}
