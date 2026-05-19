import SwiftData
import SwiftUI

struct FolioListPane: View {
    let project: Project?
    let folios: [Folio]
    @Binding var selectedFolioID: PersistentIdentifier?
    let onCreateFolio: () -> Void

    var body: some View {
        Group {
            if let project {
                folioColumn(for: project)
            } else {
                EmptyProjectContentView()
            }
        }
        .navigationSplitViewColumnWidth(min: 250, ideal: 300, max: 380)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WrimoireTheme.surface)
    }

    private func folioColumn(for project: Project) -> some View {
        folioListContent(for: project)
        .navigationTitle(project.title)
        .toolbar {
            ToolbarItem(placement: primaryActionPlacement) {
                Button("New Folio", action: onCreateFolio)
                .help("Create a folio in this project")
            }
        }
    }

    @ViewBuilder
    private func folioListContent(for project: Project) -> some View {
        if folios.isEmpty {
            MinimalEmptyStateView(
                title: "No Folios Yet",
                message: "Create the first folio for \(project.title)."
            )
        } else {
            List(folios, selection: $selectedFolioID) { folio in
                FolioRow(folio: folio)
                    .tag(folio.persistentModelID)
            }
            .scrollContentBackground(.hidden)
        }
    }

    private var primaryActionPlacement: ToolbarItemPlacement {
#if os(macOS)
        .primaryAction
#else
        .topBarTrailing
#endif
    }
}

private struct EmptyProjectContentView: View {
    var body: some View {
        MinimalEmptyStateView(
            title: "Select a Project",
            message: "Choose a project to browse its folios."
        )
    }
}

private struct MinimalEmptyStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(WrimoireTheme.ink)

            Text(message)
                .font(.body)
                .foregroundStyle(WrimoireTheme.ink.opacity(0.62))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: 320)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}
