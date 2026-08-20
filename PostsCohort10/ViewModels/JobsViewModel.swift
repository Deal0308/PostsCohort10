import Foundation
import Combine

/// Manages The Muse job listings, loading state, errors, and local filters.
@MainActor
final class JobsViewModel: ObservableObject {
    @Published private(set) var jobs: [Job] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var hasLoaded = false
    @Published var searchText = ""

    private let jobService: JobService

    var filteredJobs: [Job] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return jobs
        }

        return jobs.filter { job in
            job.name.localizedCaseInsensitiveContains(query) ||
                job.company.name.localizedCaseInsensitiveContains(query) ||
                job.locations.contains { $0.name.localizedCaseInsensitiveContains(query) } ||
                job.categories.contains { $0.name.localizedCaseInsensitiveContains(query) } ||
                job.levels.contains { $0.name.localizedCaseInsensitiveContains(query) } ||
                job.tags.contains { $0.name.localizedCaseInsensitiveContains(query) }
        }
    }

    var categorySummary: String {
        let categories = jobs.flatMap(\.categoryNames)
        return Set(categories).count.formatted()
    }

    init(jobService: JobService? = nil) {
        self.jobService = jobService ?? JobService()
    }

    func loadJobs(forceRefresh: Bool = false) async {
        guard !isLoading else {
            return
        }

        if hasLoaded && !forceRefresh {
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
