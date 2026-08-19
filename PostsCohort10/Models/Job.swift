import Foundation
import UIKit

/// Represents one job listing returned by the Arbeitnow Job Board API.
struct Job: Codable, Identifiable {
    let slug: String
    let companyName: String
    let title: String
    let description: String
    let remote: Bool
    let url: String
    let tags: [String]
    let jobTypes: [String]
    let location: String
    let createdAt: Int

    var id: String {
        slug
    }

    var plainTextDescription: String {
        description.htmlStripped
    }

    var createdDate: Date? {
        Date(timeIntervalSince1970: TimeInterval(createdAt))
    }

    enum CodingKeys: String, CodingKey {
        case slug
        case companyName = "company_name"
        case title
        case description
        case remote
        case url
        case tags
        case jobTypes = "job_types"
        case location
        case createdAt = "created_at"
    }
}

extension String {
    var htmlStripped: String {
        let withLineBreaks = replacingOccurrences(of: "<br>", with: "\n")
            .replacingOccurrences(of: "<br/>", with: "\n")
            .replacingOccurrences(of: "<br />", with: "\n")
            .replacingOccurrences(of: "</li>", with: "\n")
            .replacingOccurrences(of: "</p>", with: "\n")
            .replacingOccurrences(of: "</div>", with: "\n")

        guard let data = withLineBreaks.data(using: .utf8) else {
            return withLineBreaks
        }

        if let attributed = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        ) {
            return attributed.string.cleanedWhitespace
        }

        return withLineBreaks.replacingOccurrences(
            of: "<[^>]+>",
            with: " ",
            options: .regularExpression
        )
        .cleanedWhitespace
    }

    var cleanedWhitespace: String {
        components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
