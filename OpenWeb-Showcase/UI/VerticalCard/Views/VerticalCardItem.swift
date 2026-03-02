import SwiftUI

enum HomeScreenDimensions {
    static let cardHeight: CGFloat = 180
    static let cardCornerRadius: CGFloat = 16
    static let cardElevation: CGFloat = 2

    static let paddingLarge: CGFloat = 16
    static let paddingMedium: CGFloat = 12

    static let iconContainerSize: CGFloat = 56
    static let iconContainerCornerRadius: CGFloat = 12

    static let fontSizeIcon: CGFloat = 28
    static let fontSizeCardTitle: CGFloat = 18
    static let fontSizeSection: CGFloat = 14
    static let fontSizeCardDescription: CGFloat = 13
    static let lineHeightCardDescription: CGFloat = 18
}

struct VerticalCardItem: View {
    var vertical: VerticalCard
    var onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .center, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: HomeScreenDimensions.iconContainerCornerRadius, style: .continuous)
                        .fill(vertical.color.opacity(0.15))
                        .frame(width: HomeScreenDimensions.iconContainerSize, height: HomeScreenDimensions.iconContainerSize)

                    Text(vertical.icon)
                        .font(.system(size: HomeScreenDimensions.fontSizeIcon))
                }

                Spacer().frame(height: HomeScreenDimensions.paddingMedium)

                Text(vertical.title)
                    .font(.system(size: HomeScreenDimensions.fontSizeCardTitle, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: 4)

                Text(vertical.description)
                    .font(.system(size: HomeScreenDimensions.fontSizeCardDescription))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.center)
                    .lineSpacing(HomeScreenDimensions.lineHeightCardDescription - HomeScreenDimensions.fontSizeCardDescription)
            }
            .padding(HomeScreenDimensions.paddingLarge)
            .frame(maxWidth: .infinity, minHeight: HomeScreenDimensions.cardHeight, maxHeight: HomeScreenDimensions.cardHeight)
            .background {
                RoundedRectangle(cornerRadius: HomeScreenDimensions.cardCornerRadius, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
                    .overlay {
                        RoundedRectangle(cornerRadius: HomeScreenDimensions.cardCornerRadius, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    }
            }
            .shadow(color: Color.black.opacity(0.12), radius: HomeScreenDimensions.cardElevation, x: 0, y: 2)
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
