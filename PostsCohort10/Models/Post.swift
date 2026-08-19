import Foundation

/// Represents a single post returned by the JSONPlaceholder API.
struct Post: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
