import SwiftUI

struct APIConsoleView: View {
    @ObservedObject var viewModel: APIConsoleViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    consoleHeader
                        .listRowBackground(Color.clear)
                }

                Section("Controls") {
                    Button("Load All Posts") {
                        Task { await viewModel.loadAllPosts() }
                    }

                    HStack {
                        TextField("Post ID", text: $viewModel.postIDText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .accessibilityLabel("Post ID")

                        Button("Load Post by ID") {
                            Task { await viewModel.loadPostByID() }
                        }
                    }

                    Button("Load Jobs") {
                        Task { await viewModel.loadJobs() }
                    }

                    Button("Refresh All Endpoints") {
                        Task { await viewModel.refreshAllEndpoints() }
                    }
                    .font(.headline)
                }

                Section("Endpoint Status") {
                    ForEach(viewModel.statuses) { status in
                        endpointStatusView(status)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("API Console")
        }
    }

    private var consoleHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("API Demonstration Console", systemImage: "network")
                .font(.title2.bold())
            Text("Read-only controls for the public endpoints used in this project. These APIs do not provide administrator privileges.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(LinearGradient(colors: [.indigo, .blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .foregroundStyle(.white)
    }

    private func endpointStatusView(_ status: APIConsoleEndpointStatus) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(status.name)
                    .font(.headline)
                Spacer()
                Text(status.method)
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.15), in: Capsule())
            }

            Text(status.endpoint)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)

            if status.isLoading {
                Label("Loading", systemImage: "hourglass")
                    .foregroundStyle(.secondary)
            } else if let errorMessage = status.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
            } else {
                Label(status.successMessage, systemImage: status.lastSuccessDate == nil ? "circle" : "checkmark.circle.fill")
                    .foregroundStyle(status.lastSuccessDate == nil ? Color.secondary : Color.green)
            }

            if let decodedCount = status.decodedCount {
                Text("Decoded records: \(decodedCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let lastSuccessDate = status.lastSuccessDate {
                Text("Last success: \(lastSuccessDate.formatted(date: .abbreviated, time: .standard))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    APIConsoleView(viewModel: APIConsoleViewModel())
}
