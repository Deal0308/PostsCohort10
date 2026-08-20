import Foundation

/// Top-level response returned by The Muse public jobs API.
struct JobResponse: Codable {
    let page: Int
    let pageCount: Int
    let itemsPerPage: Int
    let took: Int
    let timedOut: Bool
    let total: Int
    let results: [Job]

    enum CodingKeys: String, CodingKey {
        case page
        case pageCount = "page_count"
        case itemsPerPage = "items_per_page"
        case took
        case timedOut = "timed_out"
        case total
        case results
    }
}
