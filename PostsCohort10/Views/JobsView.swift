import SwiftUI

struct JobsView: View {
    @ObservedObject var viewModel: JobsViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var screenState: JobsScreenState {
        if viewModel.isLoading && viewModel.jobs.isEmpty { return .loading }
        if let error = viewModel.errorMessage, viewModel.jobs.isEmpty { return .error(error) }
        if viewModel.hasLoaded && viewModel.jobs.isEmpty { return .empty }
        if viewModel.hasLoaded && !viewModel.jobs.isEmpty && viewModel.filteredJobs.isEmpty { return .searchEmpty }
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
            .navigationTitle("Jobs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.loadJobs(forceRefresh: true) }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                    .accessibilityLabel("Reload jobs")
                    .accessibilityHint("Downloads the latest jobs from The Muse.")
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search title, company, location, category, or tag")
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch screenState {
        case .loading:
            stateCard(symbol: "briefcase.fill", title: "Loading Jobs", message: "Retrieving current job listings from The Muse.", showsProgress: true, actionTitle: nil, action: nil)
        case .error(let message):
            stateCard(symbol: "wifi.exclamationmark", title: "Unable to Load Jobs", message: message, showsProgress: false, actionTitle: "Try Again") {
                Task { await viewModel.loadJobs(forceRefresh: true) }
            }
        case .empty:
            stateCard(symbol: "tray", title: "No Jobs Available", message: "The Muse endpoint returned no listings.", showsProgress: false, actionTitle: "Reload Jobs") {
                Task { await viewModel.loadJobs(forceRefresh: true) }
            }
        case .searchEmpty:
            stateCard(symbol: "briefcase.circle", title: "No Matching Jobs", message: "No job matched the current search.", showsProgress: false, actionTitle: "Clear Search") {
                viewModel.searchText = ""
            }
        case .success:
            jobsList
        }
    }

    private var backgroundView: some View {
        ZStack(alignment: .top) {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            LinearGradient(colors: [.teal.opacity(0.22), .blue.opacity(0.14), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 320)
                .ignoresSafeArea(edges: .top)
        }
    }

    private var jobsList: some View {
        List {
            heroHeader
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 10, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            if viewModel.isLoading {
                Label("Refreshing jobs...", systemImage: "arrow.clockwise")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            ForEach(viewModel.filteredJobs) { job in
                NavigationLink {
                    JobDetailView(job: job)
                } label: {
                    JobRowView(job: job)
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable { await viewModel.loadJobs(forceRefresh: true) }
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("The Muse Jobs", systemImage: "briefcase.fill")
                .font(.title2.bold())
            Text("Current roles from The Muse public jobs API")
                .font(.subheadline)
                .opacity(0.86)
            HStack {
                Label("\(viewModel.jobs.count) loaded", systemImage: "list.bullet.rectangle")
                Label("\(viewModel.categorySummary) categories", systemImage: "folder.fill")
            }
            .font(.caption.weight(.bold))
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LinearGradient(colors: [.teal, .blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .teal.opacity(0.22), radius: 16, x: 0, y: 10)
    }

    private func stateCard(symbol: String, title: String, message: String, showsProgress: Bool, actionTitle: String?, action: (() -> Void)?) -> some View {
        VStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.teal)
                .accessibilityHidden(true)
            if showsProgress { ProgressView().tint(.teal) }
            Text(title).font(.title3.bold())
            Text(message).font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .accessibilityLabel(actionTitle)
                    .accessibilityHint("Attempts to load jobs again.")
            }
        }
        .padding(24)
        .frame(maxWidth: 420)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}

private enum JobsScreenState: Equatable {
    case loading
    case error(String)
    case empty
    case searchEmpty
    case success
}

#Preview {
    JobsView(viewModel: JobsViewModel())
}
