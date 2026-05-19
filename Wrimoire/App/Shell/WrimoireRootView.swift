import SwiftData
import SwiftUI

struct WrimoireRootView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var writingLayoutController: WritingLayoutController
    @Query(sort: [SortDescriptor(\Project.createdAt)]) private var projects: [Project]

    @State private var selectedProjectID: PersistentIdentifier?
    @State private var selectedFolioID: PersistentIdentifier?
    @State private var storageAlert: StorageAlert?
    @State private var isPresentingProjectPrompt = false
    @State private var pendingProjectTitle = ""

    private var selectedProject: Project? {
        projects.first { $0.persistentModelID == selectedProjectID }
    }

    private var sortedFolios: [Folio] {
        guard let selectedProject else {
            return []
        }

        return (selectedProject.folios ?? []).sorted { left, right in
            if left.updatedAt == right.updatedAt {
                return left.createdAt > right.createdAt
            }

            return left.updatedAt > right.updatedAt
        }
    }

    private var selectedFolio: Folio? {
        sortedFolios.first { $0.persistentModelID == selectedFolioID }
    }

    private var projectIDs: [PersistentIdentifier] {
        projects.map(\.persistentModelID)
    }

    private var folioIDs: [PersistentIdentifier] {
        sortedFolios.map(\.persistentModelID)
    }

    var body: some View {
        NavigationSplitView(
            columnVisibility: $writingLayoutController.columnVisibility,
            preferredCompactColumn: $writingLayoutController.preferredCompactColumn
        ) {
            ProjectSidebarView(
                projects: projects,
                selectedProjectID: $selectedProjectID,
                onAddProject: presentProjectCreationPrompt
            )
        } content: {
            FolioListPane(
                project: selectedProject,
                folios: sortedFolios,
                selectedFolioID: $selectedFolioID,
                onCreateFolio: createFolio
            )
        } detail: {
            ProjectWorkspaceView(
                project: selectedProject,
                folio: selectedFolio
            )
        }
        .navigationSplitViewStyle(.prominentDetail)
        .tint(.accentColor)
#if os(macOS)
        .background(
            MacNavigationSplitViewConfigurator(
                writingLayoutController: writingLayoutController
            )
        )
        .toolbarBackground(.visible, for: .windowToolbar)
        .toolbarBackground(WrimoireTheme.canvas, for: .windowToolbar)
#endif
        .onAppear {
            reconcileProjectSelection()
            reconcileFolioSelection()
        }
        .onChange(of: projectIDs) { _, _ in
            reconcileProjectSelection()
            reconcileFolioSelection()
        }
        .onChange(of: selectedProjectID) { _, _ in
            reconcileFolioSelection()
        }
        .onChange(of: folioIDs) { _, _ in
            reconcileFolioSelection()
        }
        .alert(
            "New Project",
            isPresented: $isPresentingProjectPrompt
        ) {
            TextField("Project name", text: $pendingProjectTitle)
            Button("Cancel", role: .cancel) {
                pendingProjectTitle = ""
            }
            Button("Create") {
                createProject(named: pendingProjectTitle)
            }
            .disabled(trimmedPendingProjectTitle.isEmpty)
        } message: {
            Text("Choose a name for the project before creating it.")
        }
        .alert(
            "Couldn’t Save Changes",
            isPresented: Binding(
                get: { storageAlert != nil },
                set: { isPresented in
                    if isPresented == false {
                        storageAlert = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(storageAlert?.message ?? "")
        }
    }

    private func presentProjectCreationPrompt() {
        pendingProjectTitle = nextProjectTitle()
        isPresentingProjectPrompt = true
    }

    private func createProject(named name: String) {
        let trimmedTitle = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedTitle.isEmpty == false else {
            return
        }

        let nextProject = Project(title: trimmedTitle)
        let previousSelection = selectedProjectID

        modelContext.insert(nextProject)
        selectedProjectID = nextProject.persistentModelID
        pendingProjectTitle = ""

        do {
            try modelContext.save()
        } catch {
            modelContext.delete(nextProject)
            selectedProjectID = previousSelection
            storageAlert = StorageAlert(message: error.localizedDescription)
        }
    }

    private func createFolio() {
        guard let selectedProject else {
            return
        }

        let nextFolio = Folio(
            title: "",
            project: selectedProject
        )
        let previousSelection = selectedFolioID
        let previousProjectUpdatedAt = selectedProject.updatedAt

        selectedProject.updatedAt = Date.now
        modelContext.insert(nextFolio)
        selectedFolioID = nextFolio.persistentModelID

        do {
            try modelContext.save()
        } catch {
            modelContext.delete(nextFolio)
            selectedProject.updatedAt = previousProjectUpdatedAt
            selectedFolioID = previousSelection
            storageAlert = StorageAlert(message: error.localizedDescription)
        }
    }

    private func reconcileProjectSelection() {
        guard projects.isEmpty == false else {
            selectedProjectID = nil
            return
        }

        if let selectedProjectID,
           projects.contains(where: { $0.persistentModelID == selectedProjectID }) {
            return
        }

        selectedProjectID = projects.first?.persistentModelID
    }

    private func reconcileFolioSelection() {
        guard sortedFolios.isEmpty == false else {
            selectedFolioID = nil
            return
        }

        if let selectedFolioID,
           sortedFolios.contains(where: { $0.persistentModelID == selectedFolioID }) {
            return
        }

        selectedFolioID = sortedFolios.first?.persistentModelID
    }

    private func nextProjectTitle() -> String {
        let baseTitle = "New Project"
        guard projects.contains(where: { $0.title == baseTitle }) == false else {
            var index = 2

            while projects.contains(where: { $0.title == "\(baseTitle) \(index)" }) {
                index += 1
            }

            return "\(baseTitle) \(index)"
        }

        return baseTitle
    }

    private var trimmedPendingProjectTitle: String {
        pendingProjectTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}
