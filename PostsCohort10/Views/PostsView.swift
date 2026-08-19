import SwiftUI

/// Main screen that loads posts and displays loading, success, empty, search, and error states.
struct PostsView: View {
    @ObservedObject var viewModel: PostsViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var trimmedSearchText: String {
        viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var screenState: ScreenState {
        if viewModel.isLoading && viewModel.posts.isEmpty {
            return .loading
        }

        if let errorMessage = viewModel.errorMessage, viewModel.posts.isEmpty {
            return .error(errorMessage)
        }

        if viewModel.hasRequestedPosts && viewModel.posts.isEmpty {
            return .empty
        }

        if viewModel.hasSubmittedSearch, let message = viewModel.searchErrorMessage, viewModel.searchResults.isEmpty {
            return .searchError(message)
        }

        if viewModel.hasSubmittedSearch && viewModel.searchResults.isEmpty {
            return .searchEmpty
        }

        return .success
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView

                contentView
                    .transition(reduceMotion ? .identity : .opacity.combined(with: .scale(scale: 0.98)))
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: screenState)
            }
            .navigationTitle("Posts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    reloadButton
                }
            }
            .searchable(
                text: $viewModel.searchText,
                prompt: "Search title, content, or post number"
            )
            .onSubmit(of: .search) {
                guard !viewModel.isSearching else {
                    return
                }

                Task {
                    await viewModel.searchPosts()
                }
            }
            .task {
                if viewModel.posts.isEmpty {
                    await viewModel.loadPosts()
                }
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch screenState {
        case .loading:
            loadingView
        case .error(let message):
            errorView(message: message)
        case .empty:
            emptyView
        case .searchError(let message):
            searchErrorView(message: message)
        case .searchEmpty:
            searchEmptyView
        case .success:
            postsList
        }
    }

    private var backgroundView: some View {
        ZStack(alignment: .top) {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.blue.opacity(0.24),
                    Color.indigo.opacity(0.18),
                    Color.cyan.opacity(0.10),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 320)
            .ignoresSafeArea(edges: .top)
        }
    }

    private var reloadButton: some View {
        Button {
            Task {
                await viewModel.loadPosts()
            }
        } label: {
            Image(systemName: "arrow.clockwise")
                .rotationEffect(.degrees(viewModel.isLoading && !reduceMotion ? 180 : 0))
        }
        .disabled(viewModel.isLoading)
        .accessibilityLabel("Reload posts")
        .accessibilityHint("Downloads the latest posts from JSONPlaceholder.")
    }

    private var postsList: some View {
        List {
            heroHeader
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 10, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            if viewModel.hasSubmittedSearch {
                searchResultsSummary
                    .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 4, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            ForEach(viewModel.displayedPosts) { post in
                NavigationLink {
                    PostDetailView(post: post)
                } label: {
                    PostRowView(post: post)
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable {
            await viewModel.loadPosts()
        }
    }

    private var searchResultsSummary: some View {
        HStack(spacing: 8) {
            if viewModel.isSearching {
                ProgressView()
                    .controlSize(.small)
                    .tint(.indigo)
            } else {
                Image(systemName: "magnifyingglass")
                    .font(.caption.weight(.semibold))
                    .accessibilityHidden(true)
            }

            Text(searchResultsText)
                .font(.subheadline.weight(.semibold))

            Spacer(minLength: 8)

            Button("Clear Search") {
                viewModel.clearSearch()
            }
            .font(.caption.weight(.semibold))
            .buttonStyle(.borderless)
            .accessibilityLabel("Clear Search")
            .accessibilityHint("Clears the search field and restores all downloaded posts.")
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.86), in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
    }

    private var searchResultsText: String {
        if viewModel.isSearching {
            return "Searching post #\(trimmedSearchText)"
        }

        let count = viewModel.displayedPosts.count

        if count == 0 {
            return "No matching posts"
        }

        if count == 1 {
            return "1 result"
        }

        return "\(count) results"
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .blue, .indigo],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                        .accessibilityHidden(true)
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Explore Posts")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    Text("Ideas and conversations from the community")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.84))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 10) {
                Label("\(viewModel.posts.count) posts", systemImage: "doc.text")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.16), in: Capsule())

                Label("JSONPlaceholder", systemImage: "checkmark.seal.fill")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.14), in: Capsule())
            }
            .foregroundStyle(.white)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [.blue, .indigo, .purple.opacity(0.88)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.24), lineWidth: 1)
        }
        .shadow(color: .indigo.opacity(0.22), radius: 16, x: 0, y: 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Explore Posts. Ideas and conversations from the community. \(viewModel.posts.count) posts loaded from JSONPlaceholder.")
    }

    private var loadingView: some View {
        StateCardView(
            symbolName: "text.bubble.fill",
            title: "Loading Posts",
            message: "Retrieving the latest posts from JSONPlaceholder.",
            accentColor: .blue,
            showsProgress: true,
            buttonTitle: nil,
            accessibilityHint: "",
            action: nil
        )
        .padding(24)
    }

    private func errorView(message: String) -> some View {
        StateCardView(
            symbolName: "wifi.exclamationmark",
            title: "Unable to Load Posts",
            message: message,
            accentColor: .orange,
            showsProgress: false,
            buttonTitle: "Try Again",
            accessibilityHint: "Attempts to download posts again."
        ) {
            Task {
                await viewModel.loadPosts()
            }
        }
        .padding(24)
    }

    private var emptyView: some View {
        StateCardView(
            symbolName: "tray",
            title: "No Posts Available",
            message: "The request finished, but the API did not return any posts.",
            accentColor: .cyan,
            showsProgress: false,
            buttonTitle: "Reload Posts",
            accessibilityHint: "Downloads posts again."
        ) {
            Task {
                await viewModel.loadPosts()
            }
        }
        .padding(24)
    }

    private func searchErrorView(message: String) -> some View {
        StateCardView(
            symbolName: "exclamationmark.magnifyingglass",
            title: "Post Search Failed",
            message: message,
            accentColor: .orange,
            showsProgress: false,
            buttonTitle: "Clear Search",
            accessibilityHint: "Clears the failed search and restores all downloaded posts."
        ) {
            viewModel.clearSearch()
        }
        .padding(24)
    }

    private var searchEmptyView: some View {
        StateCardView(
            symbolName: "doc.text.magnifyingglass",
            title: "No Matching Posts",
            message: "No title or content matched \"\(trimmedSearchText)\".",
            accentColor: .indigo,
            showsProgress: false,
            buttonTitle: "Clear Search",
            accessibilityHint: "Clears the search field and restores the complete posts list."
        ) {
            viewModel.clearSearch()
        }
        .padding(24)
    }
}

private enum ScreenState: Equatable {
    case loading
    case error(String)
    case empty
    case searchError(String)
    case searchEmpty
    case success
}

private struct StateCardView: View {
    let symbolName: String
    let title: String
    let message: String
    let accentColor: Color
    let showsProgress: Bool
    let buttonTitle: String?
    let accessibilityHint: String
    let action: (() -> Void)?

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [accentColor, .indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: symbolName)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white)
                    .accessibilityHidden(true)
            }
            .frame(width: 72, height: 72)

            if showsProgress {
                ProgressView()
                    .tint(accentColor)
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(.primary)

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let buttonTitle, let action {
                Button(action: action) {
                    Text(buttonTitle)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityLabel(buttonTitle)
                .accessibilityHint(accessibilityHint)
            }
        }
        .padding(24)
        .frame(maxWidth: 420)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(accentColor.opacity(0.18), lineWidth: 1)
        }
        .shadow(color: accentColor.opacity(0.14), radius: 16, x: 0, y: 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Posts View") {
    PostsView(viewModel: PostsViewModel())
}

#Preview("Posts View Dark") {
    PostsView(viewModel: PostsViewModel())
        .preferredColorScheme(.dark)
}
