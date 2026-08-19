import SwiftUI

struct RootTabView: View {
    @StateObject private var postsViewModel = PostsViewModel()
    @StateObject private var jobsViewModel = JobsViewModel()
    @StateObject private var apiConsoleViewModel = APIConsoleViewModel()

    var body: some View {
        TabView {
            PostsView(viewModel: postsViewModel)
                .tabItem {
                    Label("Posts", systemImage: "text.bubble.fill")
                }

            JobsView(viewModel: jobsViewModel)
                .tabItem {
                    Label("Jobs", systemImage: "briefcase.fill")
                }

            APIConsoleView(viewModel: apiConsoleViewModel)
                .tabItem {
                    Label("API", systemImage: "network")
                }
        }
        .task {
            async let postsLoad: Void = postsViewModel.loadPosts()
            async let jobsLoad: Void = jobsViewModel.loadJobs()
            _ = await (postsLoad, jobsLoad)
        }
    }
}

#Preview {
    RootTabView()
}
