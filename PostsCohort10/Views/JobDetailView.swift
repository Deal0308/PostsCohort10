import SwiftUI

struct JobDetailView: View {
    let job: Job

    private var formattedDate: String? {
        job.publishedDate?.formatted(date: .abbreviated, time: .omitted)
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
            Label("The Muse listing", systemImage: "briefcase.fill")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.teal)

            Text(job.name)
                .font(.title2.bold())
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(job.companyDisplayName)
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
            Label(job.locationNames, systemImage: "mappin.and.ellipse")

            if !job.levelNames.isEmpty {
                Label(job.levelNames.joined(separator: ", "), systemImage: "chart.bar.fill")
            }

            if !job.categoryNames.isEmpty {
                Label(job.categoryNames.joined(separator: ", "), systemImage: "folder.fill")
            }

            if let formattedDate {
                Label("Published \(formattedDate)", systemImage: "calendar")
            }

            if !job.tagNames.isEmpty {
                FlowTagsView(tags: job.tagNames, accentColor: .teal)
            }

            if let applicationURL = job.applicationURL {
                Link(destination: applicationURL) {
                    Label("View Job on The Muse", systemImage: "arrow.up.right.square")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityHint("Opens the original The Muse job listing in a browser.")
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
        JobDetailView(
            job: Job(
                contents: "<p>Build useful software.</p>",
                name: "Senior SwiftUI Developer",
                type: "external",
                publicationDate: "2026-08-20T05:00:07Z",
                shortName: "swiftui-developer",
                modelType: "jobs",
                id: 1,
                locations: [JobAttribute(name: "Remote", shortName: nil)],
                categories: [JobAttribute(name: "Software Engineering", shortName: nil)],
                levels: [JobAttribute(name: "Senior Level", shortName: "senior")],
                tags: [JobAttribute(name: "Swift", shortName: "swift")],
                refs: JobReferences(landingPage: "https://www.themuse.com"),
                company: JobCompany(id: 1, shortName: "example", name: "Example Co")
            )
        )
    }
}
