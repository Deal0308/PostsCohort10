import Foundation
import Combine

/// Manages job listings, loading state, errors, and local filters.
@MainActor
final class JobsViewModel: ObservableObject {
    @Published private(set) var jobs: [Job] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var hasLoaded = false
    @Published var searchText = ""
    @Published var remoteOnly = false

    private let jobService: JobService

    var filteredJobs: [Job] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return jobs.filter { job in
            let matchesRemote = !remoteOnly || job.remote
            let matchesQuery = query.isEmpty ||
                job.title.localizedCaseInsensitiveContains(query) ||
                job.companyName.localizedCaseInsensitiveContains(query) ||
                job.location.localizedCaseInsensitiveContains(query) ||
                job.tags.contains { $0.localizedCaseInsensitiveContains(query) } ||
                job.jobTypes.contains { $0.localizedCaseInsensitiveContains(query) }

            return matchesRemote && matchesQuery
        }
    }

    var remoteJobCount: Int {
        jobs.filter(\.remote).count
    }

    init(jobService: JobService? = nil) {
        self.jobService = jobService ?? JobService()
    }

    func loadJobs() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
            hasLoaded = true
        }

        do {
            jobs = try await jobService.fetchJobs()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
