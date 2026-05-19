import Foundation
import SwiftData
import Testing
@testable import Wrimoire

@Suite("Wrimoire Data Model")
struct WrimoireDataModelTests {
    @MainActor
    @Test("In-memory container supports Project and Folio persistence")
    func inMemoryContainerSupportsProjectAndFolioPersistence() throws {
        let container = try WrimoireDataModel.makeContainer(inMemory: true)
        let context = container.mainContext

        let project = Project(title: "Archive")
        let folio = Folio(title: "First Folio", body: "A beginning", project: project)

        context.insert(project)
        context.insert(folio)
        try context.save()

        try #expect(fetchCount(Project.self, in: context) == 1)
        try #expect(fetchCount(Folio.self, in: context) == 1)
    }

    @MainActor
    @Test("App bootstrap returns local mode when cloud sync is disabled")
    func bootstrapReturnsLocalOnlyModeWhenCloudSyncIsDisabled() throws {
        let storeDirectory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        let storeURL = storeDirectory.appending(path: "Wrimoire.store", directoryHint: .notDirectory)

        let bootstrap = try WrimoireDataModel.makeAppContainer(
            preferCloudSync: false,
            cloudKitContainerIdentifier: "iCloud.com.example.WrimoireTests",
            storeURL: storeURL
        )

        #expect(bootstrap.mode == .localOnly)
        #expect(bootstrap.fallbackError == nil)
        #expect(FileManager.default.fileExists(atPath: storeDirectory.path()))
    }

    @MainActor
    @Test("App bootstrap falls back to local mode when cloud bootstrap fails")
    func bootstrapFallsBackToLocalModeWhenCloudBootstrapFails() throws {
        let expectedError = NSError(domain: "WrimoireTests", code: 51)

        let bootstrap = try WrimoireDataModel.makeAppContainer(
            preferCloudSync: true,
            cloudKitContainerIdentifier: "iCloud.com.example.WrimoireTests",
            cloudContainerFactory: {
                throw expectedError
            },
            localContainerFactory: {
                try WrimoireDataModel.makeContainer(inMemory: true)
            }
        )

        #expect(bootstrap.mode == .localFallbackFromCloud)
        let fallbackError = try #require(bootstrap.fallbackError as NSError?)
        #expect(fallbackError.domain == expectedError.domain)
        #expect(fallbackError.code == expectedError.code)
    }

    @MainActor
    @Test("App bootstrap reports cloud-backed mode when cloud bootstrap succeeds")
    func bootstrapReportsCloudBackedModeWhenCloudBootstrapSucceeds() throws {
        let bootstrap = try WrimoireDataModel.makeAppContainer(
            preferCloudSync: true,
            cloudKitContainerIdentifier: "iCloud.com.example.WrimoireTests",
            cloudContainerFactory: {
                try WrimoireDataModel.makeContainer(inMemory: true)
            },
            localContainerFactory: {
                Issue.record("Local fallback should not run during the cloud-backed success case.")
                return try WrimoireDataModel.makeContainer(inMemory: true)
            }
        )

        #expect(bootstrap.mode == .cloudBacked)
        #expect(bootstrap.fallbackError == nil)
    }
}
