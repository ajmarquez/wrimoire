import Foundation
import SwiftData

enum WrimoireDataModel {
    enum AppContainerMode: Equatable {
        case localOnly
        case cloudBacked
        case localFallbackFromCloud
    }

    struct AppContainerBootstrapResult {
        let container: ModelContainer
        let mode: AppContainerMode
        let fallbackError: Error?
    }

    static let persistentStoreFileName = "Wrimoire.store"

    static let schema = Schema([
        Project.self,
        Folio.self
    ])

    static func makeContainer(
        inMemory: Bool = false,
        storeURL: URL? = nil,
        fileManager: FileManager = .default,
        cloudKitDatabase: ModelConfiguration.CloudKitDatabase = .none
    ) throws -> ModelContainer {
        let configuration: ModelConfiguration

        if inMemory {
            configuration = ModelConfiguration(
                "Wrimoire",
                schema: schema,
                isStoredInMemoryOnly: true,
                cloudKitDatabase: .none
            )
        } else {
            let resolvedStoreURL = try storeURL ?? persistentStoreURL(fileManager: fileManager)
            try bootstrapPersistentStoreDirectory(for: resolvedStoreURL, fileManager: fileManager)
            configuration = ModelConfiguration(
                "Wrimoire",
                schema: schema,
                url: resolvedStoreURL,
                cloudKitDatabase: cloudKitDatabase
            )
        }

        return try ModelContainer(for: schema, configurations: [configuration])
    }

    @MainActor
    static func makeAppContainer(
        preferCloudSync: Bool,
        cloudKitContainerIdentifier: String,
        storeURL: URL? = nil,
        fileManager: FileManager = .default,
        cloudContainerFactory: (() throws -> ModelContainer)? = nil,
        localContainerFactory: (() throws -> ModelContainer)? = nil
    ) throws -> AppContainerBootstrapResult {
        let resolvedStoreURL = try storeURL ?? persistentStoreURL(fileManager: fileManager)
        let defaultFactory: (ModelConfiguration.CloudKitDatabase) throws -> ModelContainer = { cloudDatabase in
            try makeContainer(
                storeURL: resolvedStoreURL,
                fileManager: fileManager,
                cloudKitDatabase: cloudDatabase
            )
        }
        let buildCloudContainer = cloudContainerFactory ?? {
            try defaultFactory(.private(cloudKitContainerIdentifier))
        }
        let buildLocalContainer = localContainerFactory ?? {
            try defaultFactory(.none)
        }

        guard preferCloudSync else {
            return AppContainerBootstrapResult(
                container: try buildLocalContainer(),
                mode: .localOnly,
                fallbackError: nil
            )
        }

        do {
            return AppContainerBootstrapResult(
                container: try buildCloudContainer(),
                mode: .cloudBacked,
                fallbackError: nil
            )
        } catch {
            return AppContainerBootstrapResult(
                container: try buildLocalContainer(),
                mode: .localFallbackFromCloud,
                fallbackError: error
            )
        }
    }

    static func persistentStoreURL(fileManager: FileManager = .default) throws -> URL {
        let applicationSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let storeDirectoryURL = applicationSupportURL
            .appending(path: "Wrimoire", directoryHint: .isDirectory)
        try bootstrapPersistentStoreDirectory(for: storeDirectoryURL, fileManager: fileManager)
        return storeDirectoryURL
            .appending(path: persistentStoreFileName, directoryHint: .notDirectory)
    }

    @MainActor
    static func makePreviewContainer() throws -> ModelContainer {
        let container = try makeContainer(inMemory: true)
        try seedPreviewData(in: container.mainContext)
        return container
    }

    @MainActor
    static var previewContainer: ModelContainer {
        do {
            return try makePreviewContainer()
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error)")
        }
    }

    @MainActor
    static func seedPreviewData(in context: ModelContext) throws {
        let storyProject = Project(
            title: "Ink Garden",
            createdAt: Date(timeIntervalSince1970: 1_767_744_000),
            updatedAt: Date(timeIntervalSince1970: 1_767_830_400)
        )
        let fieldProject = Project(
            title: "Field Notes",
            createdAt: Date(timeIntervalSince1970: 1_767_225_600),
            updatedAt: Date(timeIntervalSince1970: 1_767_484_800)
        )

        let chapterFolio = Folio(
            title: "Chapter One",
            body: "The lantern woke before the house did.",
            createdAt: Date(timeIntervalSince1970: 1_767_752_800),
            updatedAt: Date(timeIntervalSince1970: 1_767_830_400),
            project: storyProject
        )
        let fragmentsFolio = Folio(
            title: "Image Fragments",
            body: "Sea salt on cuffs. Rain on stone. Keys under the tongue.",
            createdAt: Date(timeIntervalSince1970: 1_767_571_200),
            updatedAt: Date(timeIntervalSince1970: 1_767_657_600),
            project: storyProject
        )

        context.insert(storyProject)
        context.insert(fieldProject)
        context.insert(chapterFolio)
        context.insert(fragmentsFolio)
        try context.save()
    }

    private static func bootstrapPersistentStoreDirectory(
        for url: URL,
        fileManager: FileManager
    ) throws {
        let directoryURL = url.hasDirectoryPath ? url : url.deletingLastPathComponent()
        guard fileManager.fileExists(atPath: directoryURL.path()) == false else {
            return
        }

        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
    }
}
