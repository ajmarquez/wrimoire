import SwiftUI

struct SidebarProjectRow: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(project.title)
                .font(.headline)
                .foregroundStyle(WrimoireTheme.ink)

            Text("\(project.folioCount) \(project.folioCount == 1 ? "folio" : "folios")")
                .font(.caption)
                .foregroundStyle(WrimoireTheme.ink.opacity(0.60))
        }
        .padding(.vertical, 6)
    }
}
