import SwiftData

@MainActor
func fetchCount<Model: PersistentModel>(
    _ model: Model.Type,
    in context: ModelContext
) throws -> Int {
    try context.fetchCount(FetchDescriptor<Model>())
}
