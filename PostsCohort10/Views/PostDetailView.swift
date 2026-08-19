import SwiftUI

/// Displays the full content for one downloaded post.
struct PostDetailView: View {
    let post: Post

    private var accentColor: Color {
        PostAccentPalette.color(for: post.userId)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard
                bodyCard
            }
            .padding(16)
        }
        .background(backgroundView)
        .navigationTitle("Post Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var backgroundView: some View {
        ZStack(alignment: .top) {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            LinearGradient(
                colors: [accentColor.opacity(0.20), .indigo.opacity(0.12), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 260)
            .ignoresSafeArea(edges: .top)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 14) {
                avatar

                VStack(alignment: .leading, spacing: 8) {
                    Label("User \(post.userId)", systemImage: "person.crop.circle")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text("Post #\(post.id)")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(accentColor.opacity(0.14), in: Capsule())
                        .foregroundStyle(accentColor)
                }
            }

            Text(post.title.capitalized)
                .font(.title2.bold())
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(accentColor.opacity(0.20), lineWidth: 1)
        }
        .shadow(color: accentColor.opacity(0.14), radius: 16, x: 0, y: 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Post details. User \(post.userId). Post number \(post.id). \(post.title.capitalized).")
    }

    private var bodyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Post Body", systemImage: "quote.bubble")
                .font(.headline)
                .foregroundStyle(accentColor)

            Text(post.body)
                .font(.body)
                .lineSpacing(4)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [accentColor, accentColor.opacity(0.58)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: "person.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .accessibilityHidden(true)
        }
        .frame(width: 64, height: 64)
        .overlay {
            Circle()
                .stroke(.white.opacity(0.65), lineWidth: 1)
        }
        .accessibilityLabel("User avatar")
    }
}

#Preview("Post Detail - Light") {
    NavigationStack {
        PostDetailView(
            post: Post(
                userId: 2,
                id: 14,
                title: "sample detail post title",
                body: "This preview shows the full post body in the detail screen. Preview data is only used by SwiftUI previews and does not replace the live API response."
            )
        )
    }
}

#Preview("Post Detail - Dark") {
    NavigationStack {
        PostDetailView(
            post: Post(
                userId: 5,
                id: 42,
                title: "dark mode sample detail post title",
                body: "This preview helps confirm the detail screen remains readable in Dark Mode with semantic colors and a restrained accent palette."
            )
        )
    }
    .preferredColorScheme(.dark)
}
