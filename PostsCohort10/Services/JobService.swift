import Foundation

/// Handles Arbeitnow job board endpoint calls.
struct JobService {
    private let endpoint = "https://www.arbeitnow.com/api/job-board-api"
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchJobs() async throws -> [Job] {
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }

        let response = try await apiClient.fetch(from: url, as: JobResponse.self)

        guard !response.data.isEmpty else {
            throw APIError.emptyResponse
        }

        return response.data
    }
}
