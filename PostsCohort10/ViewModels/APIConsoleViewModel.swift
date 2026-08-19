import Foundation
import Combine

struct APIConsoleEndpointStatus: Identifiable {
    let id: String
    let name: String
    let method: String
    let endpoint: String
    var isLoading = false
    var successMessage = "Not run yet"
    var decodedCount: Int?
    var lastSuccessDate: Date?
    var errorMessage: String?
}

/// Read-only demo console for manually triggering each public API endpoint.
@MainActor
final class APIConsoleViewModel: ObservableObject {
    @Published var postIDText = "25"
    @Published private(set) var statuses: [APIConsoleEndpointStatus] = [
        APIConsoleEndpointStatus(
            id: "all-posts",
            name: "All Posts",
            method: "GET",
            endpoint: "https://jsonplaceholder.typicode.com/posts"
        ),
        APIConsoleEndpointStatus(
            id: "post-by-id",
            name: "Post by ID",
            method: "GET",
            endpoint: "https://jsonplaceholder.typicode.com/posts/{id}"
        ),
        APIConsoleEndpointStatus(
            id: "jobs",
            name: "Arbeitnow Jobs",
            method: "GET",
            endpoint: "https://www.arbeitnow.com/api/job-board-api"
        )
    ]

    private let postService: PostService
    private let jobService: JobService

    init(postService: PostService? = nil, jobService: JobService? = nil) {
        self.postService = postService ?? PostService()
        self.jobService = jobService ?? JobService()
    }

    func loadAllPosts() async {
        await runEndpoint(id: "all-posts") {
            let posts = try await postService.fetchPosts()
            return ("Decoded all posts", posts.count)
        }
    }

    func loadPostByID() async {
        await runEndpoint(id: "post-by-id") {
            guard let postID = Int(postIDText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                throw APIError.invalidPostID
            }

            _ = try await postService.fetchPost(id: postID)
            return ("Decoded Post #\(postID)", 1)
        }
    }

    func loadJobs() async {
        await runEndpoint(id: "jobs") {
            let jobs = try await jobService.fetchJobs()
            return ("Decoded Arbeitnow jobs", jobs.count)
        }
    }

    func refreshAllEndpoints() async {
        async let posts: Void = loadAllPosts()
        async let postByID: Void = loadPostByID()
        async let jobs: Void = loadJobs()
        _ = await (posts, postByID, jobs)
    }

    private func runEndpoint(
        id: String,
        operation: () async throws -> (message: String, count: Int)
    ) async {
        updateStatus(id: id) { status in
            status.isLoading = true
            status.errorMessage = nil
        }

        do {
            let result = try await operation()
            updateStatus(id: id) { status in
                status.isLoading = false
                status.successMessage = result.message
                status.decodedCount = result.count
                status.lastSuccessDate = Date()
                status.errorMessage = nil
            }
        } catch {
            updateStatus(id: id) { status in
                status.isLoading = false
                status.errorMessage = error.localizedDescription
            }
        }
    }

    private func updateStatus(id: String, update: (inout APIConsoleEndpointStatus) -> Void) {
        guard let index = statuses.firstIndex(where: { $0.id == id }) else {
            return
        }

        update(&statuses[index])
    }
}
