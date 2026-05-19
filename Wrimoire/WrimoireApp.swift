import SwiftData
import SwiftUI
import os

@main
struct WrimoireApp: App {
    @State private var sharedModelContainer: ModelContainer
    @StateObject private var writingLayoutController = WritingLayoutController()

    private let logger = Logger(subsystem: "com.ajmarquez.Wrimoire", category: "Storage")

    init() {
        let processInfo = ProcessInfo.processInfo
        let forceLocalStorage =
            processInfo.arguments.contains("-force-local-storage")
            || processInfo.environment["WRIMOIRE_FORCE_LOCAL_STORAGE"] == "1"
            || processInfo.environment["XCTestConfigurationFilePath"] != nil

        do {
            let bootstrapResult = try WrimoireDataModel.makeAppContainer(
                preferCloudSync: forceLocalStorage == false,
                cloudKitContainerIdentifier: Self.cloudKitContainerIdentifier
            )
            _sharedModelContainer = State(initialValue: bootstrapResult.container)
            logBootstrapResult(bootstrapResult)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(writingLayoutController)
        }
        .modelContainer(sharedModelContainer)
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1200, height: 780)
        .commands {
            SidebarCommands()

            CommandGroup(after: .sidebar) {
                Divider()

                Button("Show All Columns") {
                    writingLayoutController.showAllColumns()
                }
                .keyboardShortcut("1", modifiers: [.command, .option])

                Button("Show Folios and Editor") {
                    writingLayoutController.showFolioListAndEditor()
                }
                .keyboardShortcut("2", modifiers: [.command, .option])

                Button("Show Editor Only") {
                    writingLayoutController.showEditorOnly()
                }
                .keyboardShortcut("3", modifiers: [.command, .option])
            }
        }
#endif
    }

    private static let cloudKitContainerIdentifier = "iCloud.com.ajmarquez.Wrimoire"

    private func logBootstrapResult(_ result: WrimoireDataModel.AppContainerBootstrapResult) {
        switch result.mode {
        case .localOnly:
            logger.log("Storage bootstrap mode: local only")
        case .cloudBacked:
            logger.log("Storage bootstrap mode: cloud backed")
        case .localFallbackFromCloud:
            logger.error(
                "Cloud bootstrap unavailable; using local storage. error=\(String(describing: result.fallbackError))"
            )
        }
    }
}
