import SwiftUI

struct VerticalCardItem: View {
    private struct Metrics {
        static let cardHeight: CGFloat = 180
        static let cardCornerRadius: CGFloat = 16
        static let cardElevation: CGFloat = 2
        static let paddingLarge: CGFloat = 16
        static let paddingMedium: CGFloat = 12
        static let iconContainerSize: CGFloat = 56
        static let iconContainerCornerRadius: CGFloat = 12
        static let fontSizeIcon: CGFloat = 28
        static let fontSizeCardTitle: CGFloat = 18
        static let fontSizeCardDescription: CGFloat = 13
        static let lineHeightCardDescription: CGFloat = 18
        static let iconBackgroundOpacity: CGFloat = 0.15
        static let borderOpacity: CGFloat = 0.08
        static let borderWidth: CGFloat = 1
        static let shadowOpacity: CGFloat = 0.12
        static let shadowY: CGFloat = 2
        static let titleDescriptionSpacing: CGFloat = 4
    }

    var vertical: VerticalCard
    var onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .center, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: Metrics.iconContainerCornerRadius, style: .continuous)
                        .fill(vertical.color.opacity(Metrics.iconBackgroundOpacity))
                        .frame(width: Metrics.iconContainerSize, height: Metrics.iconContainerSize)

                    Text(vertical.icon)
                        .font(.system(size: Metrics.fontSizeIcon))
                }

                Spacer().frame(height: Metrics.paddingMedium)

                Text(vertical.title)
                    .font(.system(size: Metrics.fontSizeCardTitle, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: Metrics.titleDescriptionSpacing)

                Text(vertical.description)
                    .font(.system(size: Metrics.fontSizeCardDescription))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.center)
                    .lineSpacing(Metrics.lineHeightCardDescription - Metrics.fontSizeCardDescription)
            }
            .padding(Metrics.paddingLarge)
            .frame(maxWidth: .infinity, minHeight: Metrics.cardHeight, maxHeight: Metrics.cardHeight)
            .background {
                RoundedRectangle(cornerRadius: Metrics.cardCornerRadius, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
                    .overlay {
                        RoundedRectangle(cornerRadius: Metrics.cardCornerRadius, style: .continuous)
                            .stroke(Color.black.opacity(Metrics.borderOpacity), lineWidth: Metrics.borderWidth)
                    }
            }
            .shadow(color: Color.black.opacity(Metrics.shadowOpacity), radius: Metrics.cardElevation, x: 0, y: Metrics.shadowY)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VerticalCardItem(
        vertical: VerticalCard(
            id: "news",
            icon: "🌍",
            title: "News",
            description: "A short description that can wrap to two lines.",
            color: .blue
        ),
        onClick: {}
    )
    .padding()
}
