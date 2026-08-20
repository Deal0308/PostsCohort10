import SwiftUI

struct JobRowView: View {
    let job: Job

    private var accentColor: Color {
        .teal
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(colors: [accentColor, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))

                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                        .accessibilityHidden(true)
                }
                .frame(width: 50, height: 50)

                VStack(alignment: .leading, spacing: 6) {
                    Text(job.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Label(job.companyDisplayName, systemImage: "building.2")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 7) {
                Label(job.locationNames, systemImage: "mappin.and.ellipse")

                if let firstLevel = job.firstLevel {
                    Label(firstLevel, systemImage: "chart.bar.fill")
                }

                if let firstCategory = job.firstCategory {
                    Label(firstCategory, systemImage: "folder.fill")
                }

                if let formattedDate = formattedDate {
                    Label("Posted \(formattedDate)", systemImage: "calendar")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if !job.tagNames.isEmpty {
                FlowTagsView(tags: Array(job.tagNames.prefix(3)), accentColor: accentColor)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(accentColor.opacity(0.18), lineWidth: 1)
        }
        .shadow(color: accentColor.opacity(0.12), radius: 10, x: 0, y: 5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(job.name), \(job.companyDisplayName), \(job.locationNames)")
    }

    private var formattedDate: String? {
        job.publishedDate?.formatted(date: .abbreviated, time: .omitted)
    }
}

struct FlowTagsView: View {
    let tags: [String]
    let accentColor: Color

    var body: some View {
        HStack(spacing: 6) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground), in: Capsule())
                    .foregroundStyle(accentColor)
            }
        }
    }
}

#Preview {
    JobRowView(
        job: Job(
            contents: "<p>Build apps.</p>",
            name: "iOS Developer",
            type: "external",
            publicationDate: "2026-08-20T05:00:07Z",
            shortName: "ios-developer",
            modelType: "jobs",
            id: 1,
            locations: [JobAttribute(name: "Houston, TX", shortName: nil)],
            categories: [JobAttribute(name: "Software Engineering", shortName: nil)],
            levels: [JobAttribute(name: "Mid Level", shortName: "mid")],
            tags: [JobAttribute(name: "Swift", shortName: "swift")],
            refs: JobReferences(landingPage: "https://www.themuse.com"),
            company: JobCompany(id: 1, shortName: "example", name: "Example Co")
        )
    )
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
