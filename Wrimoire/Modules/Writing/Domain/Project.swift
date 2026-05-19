import Foundation
import SwiftData

@Model
final class Project {
    var id: UUID = UUID()
    var title: String
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \Folio.project)
    var folios: [Folio]?

    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now,
        folios: [Folio]? = nil
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.folios = folios
    }

    var folioCount: Int {
        folios?.count ?? 0
    }
}
