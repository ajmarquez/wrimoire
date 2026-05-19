import SwiftData
import SwiftUI

struct FolioEditorView: View {
    @Environment(\.modelContext) private var modelContext

    let folio: Folio

    @State private var storageAlert: StorageAlert?

    @ScaledMetric(relativeTo: .body) private var writingColumnWidth = 760
    @ScaledMetric(relativeTo: .body) private var writingHorizontalInset = 40
    @ScaledMetric(relativeTo: .body) private var writingVerticalInset = 28

    var body: some View {
        FolioBodyTextEditor(
            text: Binding(
                get: { folio.body },
                set: updateBody
            )
        )
        .frame(minHeight: 520)
        .padding(.horizontal, writingHorizontalInset)
        .padding(.vertical, writingVerticalInset)
        .frame(maxWidth: writingColumnWidth, alignment: .leading)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(editorBackground)
        .alert(
            "Couldn’t Save Folio",
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

    private var editorBackground: some View {
        ZStack {
            WrimoireTheme.canvas
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    WrimoireTheme.surface.opacity(0.16),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    private func updateBody(_ newBody: String) {
        guard newBody != folio.body else {
            return
        }

        let previousBody = folio.body
        let previousUpdatedAt = folio.updatedAt
        let previousProjectUpdatedAt = folio.project?.updatedAt

        folio.body = newBody
        folio.updatedAt = Date.now
        folio.project?.updatedAt = Date.now

        persistChanges {
            folio.body = previousBody
            folio.updatedAt = previousUpdatedAt
            folio.project?.updatedAt = previousProjectUpdatedAt ?? previousUpdatedAt
        }
    }

    private func persistChanges(rollback: () -> Void) {
        do {
            try modelContext.save()
        } catch {
            rollback()
            storageAlert = StorageAlert(message: error.localizedDescription)
        }
    }
}
