import Foundation
import UIKit

/// Represents one job listing returned by The Muse public jobs API.
struct Job: Codable, Identifiable {
    let contents: String
    let name: String
    let type: String
    let publicationDate: String
    let shortName: String
    let modelType: String
    let id: Int
    let locations: [JobAttribute]
    let categories: [JobAttribute]
    let levels: [JobAttribute]
    let tags: [JobAttribute]
    let refs: JobReferences
    let company: JobCompany

    var companyDisplayName: String {
        company.name
    }

    var locationNames: String {
        joinedNames(from: locations, fallback: "Location not listed")
    }

    var firstCategory: String? {
        categories.first?.name
    }

    var firstLevel: String? {
        levels.first?.name
    }

    var tagNames: [String] {
        tags.map(\.name)
    }

    var categoryNames: [String] {
        categories.map(\.name)
    }

    var levelNames: [String] {
        levels.map(\.name)
    }

    var applicationURL: URL? {
        URL(string: refs.landingPage)
    }

    var publishedDate: Date? {
        ISO8601DateFormatter().date(from: publicationDate)
    }

    var plainTextDescription: String {
        contents.htmlStrippedPreservingBreaks
    }

    private func joinedNames(from attributes: [JobAttribute], fallback: String) -> String {
        let names = attributes.map(\.name).filter { !$0.isEmpty }
        return names.isEmpty ? fallback : names.joined(separator: ", ")
    }

    enum CodingKeys: String, CodingKey {
        case contents
        case name
        case type
        case publicationDate = "publication_date"
        case shortName = "short_name"
        case modelType = "model_type"
        case id
        case locations
        case categories
        case levels
        case tags
        case refs
        case company
    }
}

struct JobAttribute: Codable, Hashable {
    let name: String
    let shortName: String?

    enum CodingKeys: String, CodingKey {
        case name
        case shortName = "short_name"
    }
}

struct JobReferences: Codable {
    let landingPage: String

    enum CodingKeys: String, CodingKey {
        case landingPage = "landing_page"
    }
}

struct JobCompany: Codable {
    let id: Int
    let shortName: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case id
        case shortName = "short_name"
        case name
    }
}

extension String {
    var htmlStrippedPreservingBreaks: String {
        let withBreaks = replacingOccurrences(of: "<br>", with: "\n")
            .replacingOccurrences(of: "<br/>", with: "\n")
            .replacingOccurrences(of: "<br />", with: "\n")
            .replacingOccurrences(of: "</p>", with: "\n\n")
            .replacingOccurrences(of: "</div>", with: "\n")
            .replacingOccurrences(of: "</li>", with: "\n")

        guard let data = withBreaks.data(using: .utf8) else {
            return withBreaks.removingHTMLTags
        }

        if let attributed = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        ) {
            return attributed.string.cleanedLines
        }

        return withBreaks.removingHTMLTags
    }

    private var removingHTMLTags: String {
        replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            .cleanedLines
    }

    private var cleanedLines: String {
        components(separatedBy: .newlines)
            .map { line in
                line.components(separatedBy: .whitespacesAndNewlines)
                    .filter { !$0.isEmpty }
                    .joined(separator: " ")
            }
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
    }
}
