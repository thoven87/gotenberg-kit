//
//  ChromiumOptions.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/12/25.
//

import Logging

import class Foundation.JSONEncoder

/// ChromiumOptions for HTML and URL conversion to PDF
/// Examples of paper size (width x height):

/// Letter - 8.5 x 11 (default)
/// Legal - 8.5 x 14
/// Tabloid - 11 x 17
/// Ledger - 17 x 11
/// A0 - 33.1 x 46.8
/// A1 - 23.4 x 33.1
/// A2 - 16.54 x 23.4
/// A3 - 11.7 x 16.54
/// A4 - 8.27 x 11.7
/// A5 - 5.83 x 8.27
/// A6 - 4.13 x 5.83
public struct ChromiumOptions: Sendable {
    /// Define whether to print the entire content in one single page.
    /// default false
    public var singlePage: Bool
    /// Specify paper width using units like 72pt, 96px, 1in, 25.4mm, 2.54cm, or 6pc.
    /// Default unit is inches if unspecified. 8.5
    public var paperWidth: Double
    /// Specify paper height using units like 72pt, 96px, 1in, 25.4mm, 2.54cm, or 6pc.
    /// Default unit is inches if unspecified. 11
    public var paperHeight: Double
    /// Specify top margin width using units like 72pt, 96px, 1in, 25.4mm, 2.54cm, or 6pc.
    /// Default unit is inches if unspecified. 0.39
    public var marginTop: Double
    /// Specify bottom margin using units like 72pt, 96px, 1in, 25.4mm, 2.54cm, or 6pc.
    /// Default unit is inches if unspecified. 0.39
    public var marginBottom: Double
    /// Specify left margin using units like 72pt, 96px, 1in, 25.4mm, 2.54cm, or 6pc.
    /// Default unit is inches if unspecified. 0.39
    public var marginLeft: Double
    /// Specify right margin using units like 72pt, 96px, 1in, 25.4mm, 2.54cm, or 6pc.
    /// Default unit is inches if unspecified. 0.39
    public var marginRight: Double
    /// Define whether to prefer page size as defined by CSS.
    /// Default false
    public var preferCssPageSize: Bool
    /// Define whether the document outline should be embedded into the PDF.
    /// Default to false
    public var generateDocumentOutline: Bool
    /// Print the background graphics.
    /// Default to false
    public var printBackground: Bool
    /// Hide the default white background and allow generating PDFs with transparency.
    /// Default false
    public var omitBackground: Bool
    /// Set the paper orientation to landscape.
    /// Default false
    public var landscape: Bool
    /// The scale of the page rendering.
    /// Default 1.0
    public var scale: Double
    /// Page ranges to print, e.g., '1-5, 8, 11-13' - empty means all pages.
    /// Default empty
    public var nativePageRanges: String
    /// Duration (e.g, '5s') to wait when loading an HTML document before converting it into PDF.
    public var waitDelay: Int?
    /// The JavaScript expression to wait before converting an HTML document into PDF until it returns true.
    public var waitForExpression: String?
    /// The media type to emulate, either "screen" or "print" - empty means "print".
    /// Default print
    public var emulatedMediaType: EmulatedMediaType
    /// Cookies to store in the Chromium cookie jar (JSON format).
    public var cookies: [Cookie]?
    /// Override the default User-Agent HTTP header.
    public var userAgent: String?
    /// Extra HTTP headers to send by Chromium (JSON format).
    public var extraHttpHeaders: [String: String]?
    /// Return a 409 Conflict response if the HTTP status code from the main page is not acceptable.
    public var failOnHttpStatusCodes: [Int]
    /// Return a 409 Conflict response if the HTTP status code from at least one resource is not acceptable.
    public var failOnResourceHttpStatusCodes: [Int]
    /// Return a 409 Conflict response if Chromium fails to load at least one resource.
    /// Default false
    public var failOnResourceLoadingFailed: Bool
    /// Return a 409 Conflict response if there are exceptions in the Chromium console.
    /// Default false
    public var failOnConsoleExceptions: Bool
    /// Do not wait for Chromium network to be idle.
    /// Default true
    public var skipNetworkIdleEvent: Bool
    /// Either intervals or pages.
    public var splitMode: SplitPDFOptions.SplitPDFMode?
    /// Either the intervals or the page ranges to extract, depending on the selected mode.
    public var splitSpan: String?
    /// Specify whether to put extracted pages into a single file or as many files as there are page ranges.
    /// Only works with pages mode.
    public var splitUnify: Bool
    /// Convert the resulting PDF into the given PDF/A format.
    public var pdfFormat: PDFFormat?
    /// Enable PDF for Universal Access for optimal accessibility.
    public var pdfua: Bool
    /// PDF metadata
    public var metadata: Metadata?
    /// Tags provide a logical structure that governs how the content of the PDF is presented through assistive technology
    public var generateTaggedPdf: Bool

    private let logger = Logger(label: "com.gotenbergkit.chromiumoptions")

    public init(
        singlePage: Bool = false,
        paperWidth: Double = 8.5,
        paperHeight: Double = 11,
        marginTop: Double = 0.39,
        marginBottom: Double = 0.39,
        marginLeft: Double = 0.39,
        marginRight: Double = 0.39,
        preferCssPageSize: Bool = false,
        generateDocumentOutline: Bool = false,
        printBackground: Bool = false,
        omitBackground: Bool = false,
        landscape: Bool = false,
        scale: Double = 1.0,
        nativePageRanges: String = "",
        waitDelay: Int? = nil,
        waitForExpression: String? = nil,
        emulatedMediaType: EmulatedMediaType = .print,
        cookies: [Cookie]? = nil,
        userAgent: String = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36",
        extraHttpHeaders: [String: String]? = nil,
        failOnHttpStatusCodes: [Int] = [499, 599],
        failOnResourceHttpStatusCodes: [Int] = [],
        failOnResourceLoadingFailed: Bool = false,
        failOnConsoleExceptions: Bool = false,
        skipNetworkIdleEvent: Bool = true,
        splitMode: SplitPDFOptions.SplitPDFMode? = nil,
        splitSpan: String? = nil,
        splitUnify: Bool = false,
        pdfFormat: PDFFormat? = nil,
        pdfua: Bool = false,
        metadata: Metadata? = nil,
        generateTaggedPdf: Bool = false
    ) {
        self.singlePage = singlePage
        self.paperWidth = paperWidth
        self.paperHeight = paperHeight
        self.marginTop = marginTop
        self.marginBottom = marginBottom
        self.marginLeft = marginLeft
        self.marginRight = marginRight
        self.preferCssPageSize = preferCssPageSize
        self.generateDocumentOutline = generateDocumentOutline
        self.printBackground = printBackground
        self.omitBackground = omitBackground
        self.landscape = landscape
        self.scale = scale
        self.nativePageRanges = nativePageRanges
        self.waitDelay = waitDelay
        self.waitForExpression = waitForExpression
        self.emulatedMediaType = emulatedMediaType
        self.cookies = cookies
        self.userAgent = userAgent
        self.extraHttpHeaders = extraHttpHeaders
        self.failOnHttpStatusCodes = failOnHttpStatusCodes
        self.failOnResourceHttpStatusCodes = failOnResourceHttpStatusCodes
        self.failOnResourceLoadingFailed = failOnResourceLoadingFailed
        self.failOnConsoleExceptions = failOnConsoleExceptions
        self.skipNetworkIdleEvent = skipNetworkIdleEvent
        self.splitMode = splitMode
        self.splitSpan = splitSpan
        self.splitUnify = splitUnify
        self.pdfFormat = pdfFormat
        self.pdfua = pdfua
        self.metadata = metadata
        self.generateTaggedPdf = generateTaggedPdf
    }

    var formValues: [String: String] {
        var values: [String: String] = [:]

        values["singlePage"] = String(singlePage)
        values["paperWidth"] = String(paperWidth)
        values["paperHeight"] = String(paperHeight)
        values["marginTop"] = String(marginTop)
        values["marginBottom"] = String(marginBottom)
        values["marginLeft"] = String(marginLeft)
        values["marginRight"] = String(marginRight)
        values["preferCssPageSize"] = String(preferCssPageSize)
        values["generateDocumentOutline"] = String(generateDocumentOutline)
        values["printBackground"] = String(printBackground)
        values["omitBackground"] = String(omitBackground)
        values["landscape"] = String(landscape)
        values["scale"] = String(scale)
        values["emulatedMediaType"] = emulatedMediaType.rawValue
        values["pdfua"] = String(pdfua)
        values["splitUnify"] = String(splitUnify)
        values["generateTaggedPdf"] = String(generateTaggedPdf)

        values["failOnHttpStatusCodes"] = "[\(failOnHttpStatusCodes.map(String.init).joined(separator: ","))]"
        values["failOnConsoleExceptions"] = String(failOnConsoleExceptions)
        values["skipNetworkIdleEvent"] = String(skipNetworkIdleEvent)
        values["failOnResourceLoadingFailed"] = String(failOnResourceLoadingFailed)

        if !failOnResourceHttpStatusCodes.isEmpty {
            values["failOnResourceHttpStatusCodes"] = "[\(failOnResourceHttpStatusCodes.map(String.init).joined(separator: ","))]"
        }

        if !nativePageRanges.isEmpty {
            values["nativePageRanges"] = nativePageRanges
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

        if let splitMode = splitMode {
            values["splitMode"] = splitMode.rawValue
        }

        if let splitSpan = splitSpan {
            values["splitSpan"] = String(splitSpan)
        }

        if let extraHttpHeaders = extraHttpHeaders, !extraHttpHeaders.isEmpty {
            do {
                let headersData = try JSONEncoder().encode(extraHttpHeaders)
                values["extraHttpHeaders"] = String(decoding: headersData, as: UTF8.self)
            } catch {
                logger.error(
                    "Failed to serialize extra HTTP headers",
                    metadata: [
                        "error": .string(error.localizedDescription)
                    ]
                )
            }
        }

        if let pdfFormat = pdfFormat {
            values["pdfa"] = pdfFormat.rawValue
        }

        if let cookies = cookies, !cookies.isEmpty {
            do {
                let cookies = try JSONEncoder().encode(cookies)
                values["cookies"] = String(decoding: cookies, as: UTF8.self)
            } catch {
                logger.error(
                    "Failed to serialize extra Cookies",
                    metadata: [
                        "error": .string(error.localizedDescription)
                    ]
                )
            }
        }

        if let metadata = metadata {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .formatted(Metadata.dateFormatter())

                let data = try encoder.encode(metadata)
                values["metadata"] = String(decoding: data, as: UTF8.self)
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
