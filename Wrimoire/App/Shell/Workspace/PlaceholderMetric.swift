import SwiftUI

struct PlaceholderMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(WrimoireTheme.ink.opacity(0.55))

            Text(value)
                .font(.headline)
                .foregroundStyle(WrimoireTheme.ink)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.62))
                .stroke(Color.accentColor.opacity(0.10), lineWidth: 1)
        )
    }
}
