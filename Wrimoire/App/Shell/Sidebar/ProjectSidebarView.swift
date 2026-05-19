import SwiftData
import SwiftUI

struct ProjectSidebarView: View {
    let projects: [Project]
    @Binding var selectedProjectID: PersistentIdentifier?
    let onAddProject: () -> Void

    var body: some View {
        List(projects, selection: $selectedProjectID) { project in
            SidebarProjectRow(project: project)
                .tag(project.persistentModelID)
        }
        .navigationSplitViewColumnWidth(min: 220, ideal: 250, max: 320)
        .scrollContentBackground(.hidden)
        .background(WrimoireTheme.surface)
        .navigationTitle("Projects")
        .toolbar {
            ToolbarItem(placement: primaryActionPlacement) {
                Button("New Project", action: onAddProject)
                .help("Create a writing project")
            }
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
