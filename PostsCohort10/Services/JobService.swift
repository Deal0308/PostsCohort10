import Foundation

/// Handles The Muse public jobs endpoint calls.
struct JobService {
    private let endpoint = "https://www.themuse.com/api/public/jobs?page=1"
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchJobs() async throws -> [Job] {
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }

        let response = try await apiClient.fetch(from: url, as: JobResponse.self)

        guard !response.results.isEmpty else {
            throw APIError.emptyResponse
        }

        return response.results
    }
}
