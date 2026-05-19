import SwiftData
import Testing
@testable import Wrimoire

@Suite("Writing Persistence")
struct WritingPersistenceTests {
    @MainActor
    @Test("Project and folios round-trip through SwiftData")
    func projectAndFoliosRoundTripThroughSwiftData() throws {
        let container = try WrimoireDataModel.makeContainer(inMemory: true)
        let context = container.mainContext

        let project = Project(title: "Novel")
        let folio = Folio(title: "Scene One", body: "Rain against the window.", project: project)

        context.insert(project)
        context.insert(folio)
        try context.save()

        let projects = try context.fetch(FetchDescriptor<Project>())
        let folios = try context.fetch(FetchDescriptor<Folio>())

        #expect(projects.count == 1)
        #expect(folios.count == 1)
        #expect(projects[0].title == "Novel")
        #expect(projects[0].folioCount == 1)
        #expect(projects[0].folios?.first?.title == "Scene One")
        #expect(folios[0].project?.title == "Novel")
    }

    @MainActor
    @Test("Deleting a project cascades its folios")
    func deletingAProjectCascadesItsFolios() throws {
        let container = try WrimoireDataModel.makeContainer(inMemory: true)
        let context = container.mainContext

        let project = Project(title: "Essays")
        let firstFolio = Folio(title: "Opening", project: project)
        let secondFolio = Folio(title: "Closing", project: project)

        context.insert(project)
        context.insert(firstFolio)
        context.insert(secondFolio)
        try context.save()

        context.delete(project)
        try context.save()

        try #expect(fetchCount(Project.self, in: context) == 0)
        try #expect(fetchCount(Folio.self, in: context) == 0)
    }

    @MainActor
    @Test("Folio can persist with no project to preserve CloudKit-safe optional relationships")
    func folioCanPersistWithoutAProject() throws {
        let container = try WrimoireDataModel.makeContainer(inMemory: true)
        let context = container.mainContext

        let folio = Folio(title: "Detached Folio", body: "Still valid.")
        context.insert(folio)
        try context.save()

        let folios = try context.fetch(FetchDescriptor<Folio>())
        #expect(folios.count == 1)
        #expect(folios[0].project == nil)
    }
}
