import Foundation
import Combine

/// Manages post data, loading state, submitted search, and user-facing errors for the posts screen.
@MainActor
final class PostsViewModel: ObservableObject {
    @Published private(set) var posts: [Post] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var hasRequestedPosts = false
    @Published var searchText = ""
    @Published private(set) var searchResults: [Post] = []
    @Published private(set) var hasSubmittedSearch = false
    @Published private(set) var isSearching = false
    @Published private(set) var searchErrorMessage: String?

    private let postService: PostService

    var displayedPosts: [Post] {
        hasSubmittedSearch ? searchResults : posts
    }

    init(postService: PostService? = nil) {
        self.postService = postService ?? PostService()
    }

    func loadPosts() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
            hasRequestedPosts = true
        }

        do {
            posts = try await postService.fetchPosts()
            refreshLocalSearchResultsIfNeeded()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func searchPosts() async {
        guard !isSearching else {
            return
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            clearSearch()
            return
        }

        hasSubmittedSearch = true
        searchErrorMessage = nil

        if let requestedPostNumber = Int(query) {
            isSearching = true

            defer {
                isSearching = false
            }

            do {
                let post = try await postService.fetchPost(id: requestedPostNumber)
                searchResults = [post]
            } catch {
                searchResults = []
                searchErrorMessage = error.localizedDescription
            }
        } else {
            searchResults = posts.filter { post in
                post.title.localizedCaseInsensitiveContains(query) ||
                    post.body.localizedCaseInsensitiveContains(query)
            }
        }
    }

    func clearSearch() {
        searchText = ""
        searchResults = []
        hasSubmittedSearch = false
        searchErrorMessage = nil
    }

    private func refreshLocalSearchResultsIfNeeded() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard hasSubmittedSearch, !query.isEmpty, Int(query) == nil else {
            return
        }

        searchResults = posts.filter { post in
            post.title.localizedCaseInsensitiveContains(query) ||
                post.body.localizedCaseInsensitiveContains(query)
        }
    }
}
