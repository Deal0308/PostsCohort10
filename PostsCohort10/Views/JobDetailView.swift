import SwiftUI

struct JobDetailView: View {
    let job: Job

    private var jobURL: URL? {
        URL(string: job.url)
    }

    private var formattedDate: String? {
        guard let date = job.createdDate else { return nil }
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard
                detailsCard
                descriptionCard
            }
            .padding(16)
        }
        .background(backgroundView)
        .navigationTitle("Job Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var backgroundView: some View {
        ZStack(alignment: .top) {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            LinearGradient(colors: [.teal.opacity(0.20), .indigo.opacity(0.12), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 260)
                .ignoresSafeArea(edges: .top)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(job.remote ? "Remote role" : "On-site role", systemImage: job.remote ? "house.fill" : "building.2.fill")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(job.remote ? .teal : .indigo)

            Text(job.title)
                .font(.title2.bold())
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(job.companyName)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.teal.opacity(0.18), lineWidth: 1)
        }
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(job.location.isEmpty ? "Location not listed" : job.location, systemImage: "mappin.and.ellipse")
            Label(job.jobTypes.isEmpty ? "Job type not listed" : job.jobTypes.joined(separator: ", "), systemImage: "clock")

            if let formattedDate {
                Label("Posted \(formattedDate)", systemImage: "calendar")
            }

            if !job.tags.isEmpty {
                FlowTagsView(tags: job.tags, accentColor: .teal)
            }

            if let jobURL {
                Link(destination: jobURL) {
                    Label("View Original Job", systemImage: "arrow.up.right.square")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityHint("Opens the original Arbeitnow job listing in a browser.")
            }
        }
        .font(.body)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Description", systemImage: "doc.text")
                .font(.headline)
                .foregroundStyle(.indigo)

            Text(job.plainTextDescription.isEmpty ? "No description provided." : job.plainTextDescription)
                .font(.body)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        JobDetailView(job: Job(slug: "sample", companyName: "Example Co", title: "Senior SwiftUI Developer", description: "<p>Build useful software.</p>", remote: true, url: "https://example.com", tags: ["Swift", "iOS"], jobTypes: ["Full-time"], location: "Remote", createdAt: 1_725_000_000))
    }
}
