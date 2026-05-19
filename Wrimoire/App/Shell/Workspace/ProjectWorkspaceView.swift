import SwiftUI

struct ProjectWorkspaceView: View {
    let project: Project?
    let folio: Folio?

    var body: some View {
        ZStack {
            WrimoireTheme.canvas
                .ignoresSafeArea()

            detailContent
                .padding(detailPadding)
        }
    }

    @ViewBuilder
    private var detailContent: some View {
        if let folio {
            FolioEditorView(folio: folio)
        } else if let project {
            EmptyFolioEditorView(projectTitle: project.title)
        } else {
            EmptyWorkspaceView()
        }
    }

    private var detailPadding: CGFloat {
#if os(macOS)
        24
#else
        16
#endif
    }
}

private struct EmptyFolioEditorView: View {
    let projectTitle: String

    var body: some View {
        ContentUnavailableView(
            "Select a Folio",
            systemImage: "doc.text.magnifyingglass",
            description: Text(
                "Choose a folio from \(projectTitle) or create a new one to start writing."
            )
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(WrimoireTheme.ink, .secondary)
    }
}

private struct EmptyWorkspaceView: View {
    var body: some View {
        ContentUnavailableView(
            "Select a Project",
            systemImage: "square.split.2x1",
            description: Text("Choose a project to open its folios and editor.")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(WrimoireTheme.ink, .secondary)
    }
}
