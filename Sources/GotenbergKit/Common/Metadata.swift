import class Foundation.DateFormatter

//
//  Metadata.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/11/25.
//
#if canImport(Darwin) || compiler(<6.0)
import Foundation
#else
import FoundationEssentials
#endif

// MARK: - Document metadata
/// Writing metadata may compromise PDF/A compliance.
public struct Metadata: Codable, Sendable {
    public var author: String?
    public var copyright: String?
    public var creationDate: Date
    public var creator: String
    public var keywords: [String]
    public var marked: Bool
    public var modDate: Date
    public var pDFVersion: Double
    public var producer: String
    public var subject: String?
    public var title: String?
    /// http://nickhodge.com/blog/archives/2145
    public var trapped: Trapped?

    public struct Trapped: Sendable, Codable {
        let rawValue: _Trapped

        enum _Trapped: String, Codable {
            case `true` = "True"
            case `false` = "False"
            case unknown = "Unknown"
        }

        public static let `true`: Trapped = .init(rawValue: .true)

        public static let `false`: Trapped = .init(rawValue: .false)

        public static let unknown: Trapped = .init(rawValue: .unknown)
    }

    public init(
        author: String,
        copyright: String,
        creationDate: Date = .init(),
        creator: String = "Gotenberg",
        keywords: [String] = [],
        marked: Bool,
        modDate: Date = .init(),
        pDFVersion: Double = 1.3,
        producer: String = "Swift Gotenberg",
        subject: String,
        title: String,
        trapped: Trapped? = nil
    ) {
        self.author = author
        self.copyright = copyright
        self.creationDate = creationDate
        self.creator = creator
        self.keywords = keywords
        self.marked = marked
        self.modDate = modDate
        self.pDFVersion = pDFVersion
        self.producer = producer
        self.subject = subject
        self.title = title
        self.trapped = trapped
    }

    enum CodingKeys: String, CodingKey {
        case author = "Author"
        case copyright = "Copyright"
        case creationDate = "CreateDate"
        case creator = "Creator"
        case keywords = "Keywords"
        case marked = "Marked"
        case modDate = "ModDate"
        case pDFVersion = "PDFVersion"
        case producer = "Producer"
        case subject = "Subject"
        case title = "Title"
        case trapped = "Trapped"
    }

    package static func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss-SS:00"

        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
}
