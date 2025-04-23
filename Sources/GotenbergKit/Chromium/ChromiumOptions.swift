//
//  ChromiumOptions.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/12/25.
//

import Logging
import class Foundation.DateFormatter

#if canImport(Darwin) || compiler(<6.0)
import Foundation
#else
import FoundationEssentials
#endif

/// ChromiumOptions for HTML and URL conversion to PDF
public struct ChromiumOptions: Sendable {
    // Page settings
    public var paperWidth: Double?
    public var paperHeight: Double?
    public var marginTop: Double?
    public var marginBottom: Double?
    public var marginLeft: Double?
    public var marginRight: Double?
    public var preferCssPageSize: Bool?
    public var printBackground: Bool?
    public var landscape: Bool?
    public var scale: Double?
    public var nativePageRanges: String?

    // Headers and footers
    public var headerHTML: String?
    public var footerHTML: String?

    // Web page specific options
    public var waitDelay: Double?
    public var waitForExpression: String?
    public var userAgent: String?
    public var extraHttpHeaders: [String: String]?
    public var emulatedMediaType: EmulatedMediaType?

    // PDF metadata and format
    public var pdfFormat: PDFFormat?

    public var metadata: Metadata?

    private let logger = Logger(label: "com.gotenbergkit.chromiumoptions")

    public init(
        paperWidth: Double? = 8.5,
        paperHeight: Double? = 11,
        marginTop: Double? = 0.79,
        marginBottom: Double? = 0.79,
        marginLeft: Double? = 0.79,
        marginRight: Double? = 0.79,
        preferCssPageSize: Bool? = nil,
        printBackground: Bool? = false,
        landscape: Bool? = nil,
        scale: Double? = 1.0,
        nativePageRanges: String? = nil,
        headerHTML: String? = nil,
        footerHTML: String? = nil,
        waitDelay: Double? = nil,
        waitForExpression: String? = nil,
        userAgent: String? = "Gotenberg Swift SDK/1.0",
        extraHttpHeaders: [String: String]? = nil,
        emulatedMediaType: EmulatedMediaType? = nil,
        pdfFormat: PDFFormat? = nil,
        metadata: Metadata? = nil
    ) {
        self.paperWidth = paperWidth
        self.paperHeight = paperHeight
        self.marginTop = marginTop
        self.marginBottom = marginBottom
        self.marginLeft = marginLeft
        self.marginRight = marginRight
        self.preferCssPageSize = preferCssPageSize
        self.printBackground = printBackground
        self.landscape = landscape
        self.scale = scale
        self.nativePageRanges = nativePageRanges
        self.headerHTML = headerHTML
        self.footerHTML = footerHTML
        self.waitDelay = waitDelay
        self.waitForExpression = waitForExpression
        self.userAgent = userAgent
        self.extraHttpHeaders = extraHttpHeaders
        self.emulatedMediaType = emulatedMediaType
        self.pdfFormat = pdfFormat
        self.metadata = metadata
    }

    var formValues: [String: String] {
        var values: [String: String] = [:]

        if let paperWidth = paperWidth {
            values["paperWidth"] = "\(paperWidth)"
        }

        if let paperHeight = paperHeight {
            values["paperHeight"] = "\(paperHeight)"
        }

        if let marginTop = marginTop {
            values["marginTop"] = "\(marginTop)"
        }

        if let marginBottom = marginBottom {
            values["marginBottom"] = "\(marginBottom)"
        }

        if let marginLeft = marginLeft {
            values["marginLeft"] = "\(marginLeft)"
        }

        if let marginRight = marginRight {
            values["marginRight"] = "\(marginRight)"
        }

        if let preferCssPageSize = preferCssPageSize {
            values["preferCssPageSize"] = preferCssPageSize ? "true" : "false"
        }

        if let printBackground = printBackground {
            values["printBackground"] = printBackground ? "true" : "false"
        }

        if let landscape = landscape {
            values["landscape"] = landscape ? "true" : "false"
        }

        if let scale = scale {
            values["scale"] = "\(scale)"
        }

        if let nativePageRanges = nativePageRanges {
            values["nativePageRanges"] = nativePageRanges
        }

        if let headerHTML = headerHTML {
            values["headerHTML"] = headerHTML
        }

        if let footerHTML = footerHTML {
            values["footerHTML"] = footerHTML
        }

        if let waitDelay = waitDelay {
            values["waitDelay"] = "\(waitDelay)s"
        }

        if let waitForExpression = waitForExpression {
            values["waitForExpression"] = waitForExpression
        }

        if let userAgent = userAgent {
            values["userAgent"] = userAgent
        }

        if let extraHttpHeaders = extraHttpHeaders, !extraHttpHeaders.isEmpty {
            do {
                let headersData = try JSONEncoder().encode(extraHttpHeaders)
                if let headersString = String(data: headersData, encoding: .utf8) {
                    values["extraHttpHeaders"] = headersString
                }
            } catch {
                logger.error(
                    "Failed to serialize extra HTTP headers",
                    metadata: [
                        "error": .string(error.localizedDescription)
                    ]
                )
            }
        }

        if let emulatedMediaType = emulatedMediaType {
            values["emulatedMediaType"] = emulatedMediaType.rawValue
        }

        if let pdfFormat = pdfFormat {
            values["pdfFormat"] = pdfFormat.rawValue
        }

        if let metadata = metadata {
            do {

                let encoder = JSONEncoder()

                let formatter = DateFormatter()

                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss-SS:00"

                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)

                encoder.dateEncodingStrategy = .formatted(formatter)

                let data = try encoder.encode(metadata)
                if let metadataString = String(data: data, encoding: .utf8) {
                    values["metadata"] = metadataString
                }
            } catch {
                logger.error(
                    "Failed to serialize metadata",
                    metadata: [
                        "error": .string(error.localizedDescription)
                    ]
                )
            }
        }

        return values
    }
}
