import SwiftUI

struct JobRowView: View {
    let job: Job

    private var accentColor: Color {
        job.remote ? .teal : .indigo
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
                    Text(job.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Label(job.companyName, systemImage: "building.2")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 8) {
                Label(job.location.isEmpty ? "Location not listed" : job.location, systemImage: "mappin.and.ellipse")
                Text(job.remote ? "Remote" : "On-site")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(accentColor.opacity(0.15), in: Capsule())
                    .foregroundStyle(accentColor)
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if !job.jobTypes.isEmpty || !job.tags.isEmpty {
                FlowTagsView(tags: Array((job.jobTypes + job.tags).prefix(3)), accentColor: accentColor)
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
        .accessibilityLabel("\(job.title), \(job.companyName), \(job.location), \(job.remote ? "Remote" : "On-site")")
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
    JobRowView(job: Job(slug: "sample", companyName: "Example Co", title: "iOS Developer", description: "<p>Build apps.</p>", remote: true, url: "https://example.com", tags: ["Swift", "SwiftUI"], jobTypes: ["Full-time"], location: "Remote", createdAt: 1_725_000_000))
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
}
