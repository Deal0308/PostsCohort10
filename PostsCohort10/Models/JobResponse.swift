import Foundation

/// Top-level response returned by the Arbeitnow Job Board API.
struct JobResponse: Codable {
    let data: [Job]
}
