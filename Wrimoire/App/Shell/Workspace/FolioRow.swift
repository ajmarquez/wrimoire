import SwiftUI

struct FolioRow: View {
    let folio: Folio

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(folio.displayTitle)
                .font(.headline)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(WrimoireTheme.ink)

            Text(folio.bodyPreview)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundStyle(WrimoireTheme.ink.opacity(0.62))
        }
        .padding(.vertical, 6)
    }
}
