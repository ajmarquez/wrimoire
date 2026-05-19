import Foundation
import SwiftData

@Model
final class Folio {
    var id: UUID = UUID()
    var title: String
    var body: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    var project: Project?

    init(
        id: UUID = UUID(),
        title: String,
        body: String = "",
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now,
        project: Project? = nil
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.project = project
    }

    var bodyPreview: String {
        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedBody.isEmpty == false else {
            return "No text yet"
        }

        let nonEmptyLines = body
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }

        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           nonEmptyLines.count > 1 {
            return nonEmptyLines.dropFirst().joined(separator: " ")
        }

        return trimmedBody
    }

    var displayTitle: String {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty == false {
            return trimmedTitle
        }

        if let inferredTitle {
            return inferredTitle
        }

        return "Untitled Folio"
    }

    var wordCount: Int {
        body.split { character in
            character.isWhitespace || character.isNewline
        }.count
    }

    private var inferredTitle: String? {
        let firstLine = body
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { $0.isEmpty == false }

        guard let firstLine else {
            return nil
        }

        let maxCharacters = 60
        if firstLine.count <= maxCharacters {
            return firstLine
        }

        let truncated = firstLine.prefix(maxCharacters).trimmingCharacters(in: .whitespaces)
        return "\(truncated)…"
    }
}
