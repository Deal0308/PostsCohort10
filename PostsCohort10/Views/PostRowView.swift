import SwiftUI

/// Shared deterministic accent colors for post cards and detail views.
enum PostAccentPalette {
    static let colors: [Color] = [.blue, .indigo, .purple, .teal, .cyan, .orange]

    static func color(for userId: Int) -> Color {
        colors[abs(userId) % colors.count]
    }
}

/// Displays one post as a polished feed card.
struct PostRowView: View {
    let post: Post

    private var accentColor: Color {
        PostAccentPalette.color(for: post.userId)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            avatar

            VStack(alignment: .leading, spacing: 10) {
                metadataRow

                Text(post.title.capitalized)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(post.body)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(cardBackground)
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(accentColor)
                .frame(width: 4)
                .padding(.vertical, 14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: accentColor.opacity(0.12), radius: 10, x: 0, y: 5)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Post number \(post.id), user \(post.userId). \(post.title.capitalized). \(post.body)")
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [accentColor.opacity(0.95), accentColor.opacity(0.55)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: "person.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .accessibilityHidden(true)
        }
        .frame(width: 46, height: 46)
        .overlay {
            Circle()
                .stroke(.white.opacity(0.65), lineWidth: 1)
        }
    }

    private var metadataRow: some View {
        HStack(spacing: 8) {
            Label("User \(post.userId)", systemImage: "person.crop.circle")
                .labelStyle(.titleAndIcon)

            Text("Post #\(post.id)")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(accentColor.opacity(0.14), in: Capsule())
                .foregroundStyle(accentColor)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.secondary)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(uiColor: .secondarySystemGroupedBackground))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(accentColor.opacity(0.18), lineWidth: 1)
            }
    }
}

#Preview("Sample Post Row - Light") {
    List {
        PostRowView(
            post: Post(
                userId: 1,
                id: 1,
                title: "sample post title",
                body: "This sample body is only used for the SwiftUI preview and is not used as live application data."
            )
        )
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    .scrollContentBackground(.hidden)
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Sample Post Row - Dark") {
    List {
        PostRowView(
            post: Post(
                userId: 4,
                id: 22,
                title: "another sample post title",
                body: "Preview data helps check the card layout in Dark Mode without replacing the live API response."
            )
        )
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    .scrollContentBackground(.hidden)
    .background(Color(uiColor: .systemGroupedBackground))
    .preferredColorScheme(.dark)
}
