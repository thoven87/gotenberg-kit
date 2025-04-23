//
//  PageProperties.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/20/25.
//

import Logging

#if canImport(Darwin) || compiler(<6.0)
import Foundation
#else
import FoundationEssentials
#endif

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
public class PageProperties {
    /// Width of the paper
    public private(set) var paperWidth: Double = _PageProperties.paperWidth
    /// Height of the paper
    public private(set) var paperHeight: Double = _PageProperties.paperHeight
    /// Top margin
    public private(set) var marginTop: Double = _PageProperties.marginTop
    /// Bottom margin
    public private(set) var marginBottom: Double = _PageProperties.marginBottom
    /// Left margin
    public private(set) var marginLeft: Double = _PageProperties.marginLeft
    /// Right margin
    public private(set) var marginRight: Double = _PageProperties.marginRight
    /// Prefer CSS page size
    public private(set) var preferCSSPageSize: Bool = _PageProperties.preferCSSPageSize
    /// Should background be printed default false
    public private(set) var printBackground: Bool = _PageProperties.printBackground
    /// If document is in landscape orientation
    public private(set) var landscape: Bool = _PageProperties.landscape
    /// Scaling factor
    public private(set) var scale: Double = _PageProperties.scale
    /// PDF format
    public private(set) var pdfFormat: PDFFormat = _PageProperties.pdfFormat
    /// The native PDF format
    public private(set) var pdfUniversalAccess: Bool = _PageProperties.pdfUniversalAccess
    /// HTML header
    public private(set) var headerHTML: String? = nil
    /// HTML footer
    public private(set) var footerHTML: String? = nil
    /// How long to wait before screenshot or document convertion
    public private(set) var waitDelay: Double? = nil
    /// Expression to wait for on web
    public private(set) var waitForExpression: String? = nil
    /// Emulated media type screen | print
    public private(set) var emulatedMediaType: EmulatedMediaType? = nil
    /// Exported document metadata
    public private(set) var metadata: Metadata? = nil
    /// Should flatten document
    public private(set) var flatten: Bool = false
    /// Should merge documents
    /// Setting false will return a zip with all supported files coverted to PDF
    public private(set) var merge: Bool = false
    /// Page ranges to print, e.g., '1-5, 8, 11-13' - empty means all pages.
    /// default All pages
    public private(set) var nativePageRanges: String = _PageProperties.nativePagerRanges

    /// Specify if images are exported to PDF using
    /// a lossless compression format like PNG or compressed using the JPEG format.
    /// default false
    public private(set) var losslessImageCompression: Bool = false
    /// Specify the quality of the JPG export.
    /// A higher value produces a higher-quality image and a larger file. Between 1 and 100.
    /// default 90
    public private(set) var quality: Int = 90
    /// Specify if the resolution of each image is reduced to the
    /// resolution specified by the form field maxImageResolution.
    /// default false
    public private(set) var reduceImageResolution: Bool = false
    /// If the form field reduceImageResolution is set to true, tell
    /// if all images will be reduced to the given value in DPI.
    /// Possible values are: lowest 75, lower 150, normal  300, high 600 and highest 1200.
    public private(set) var maxImageResolution: MaxImageResolution = .normal
    /// Set the password for opening the source file.
    public private(set) var password: String? = nil

    public private(set) var nativePdfFormats: Double?

    internal let logger: Logger = Logger(label: "com.gotenberg.swift.DocumentOptionsBuilder")

    private let MINIUM_PAPER_WIDTH: Double = 1.0
    private let MINIUM_PAPER_HEIGHT: Double = 1.0
    private let MINIUM_MARGIN: Double = 0.0

    public init() {}

    /// Sets the paper height
    ///
    public func addPaperWidth(_ paperWidth: Double) throws -> PageProperties {
        guard paperWidth > MINIUM_PAPER_WIDTH else {
            throw GotenbergError.paperWidthTooSmall
        }
        self.paperWidth = paperWidth
        return self
    }

    public func addPaperHeight(_ paperHeight: Double) throws -> PageProperties {
        guard paperHeight > MINIUM_PAPER_HEIGHT else {
            throw GotenbergError.paperHeightTooSmall
        }
        self.paperHeight = paperHeight
        return self
    }

    public func addMarginTop(_ marginTop: Double) throws -> PageProperties {
        guard marginTop > MINIUM_MARGIN else {
            throw GotenbergError.marginTooSmall
        }
        self.marginTop = marginTop
        return self
    }

    public func addMarginBottom(_ marginBottom: Double) throws -> PageProperties {
        guard marginBottom > MINIUM_MARGIN else {
            throw GotenbergError.marginTooSmall
        }
        self.marginBottom = marginBottom
        return self
    }

    public func addMarginLeft(_ marginLeft: Double) throws -> PageProperties {
        guard marginLeft > MINIUM_MARGIN else {
            throw GotenbergError.marginTooSmall
        }
        self.marginLeft = marginLeft
        return self
    }

    public func addMarginRight(_ marginRight: Double) throws -> PageProperties {
        guard marginRight > MINIUM_MARGIN else {
            throw GotenbergError.marginTooSmall
        }
        self.marginRight = marginRight
        return self
    }

    public func addPreferCSSPageSize(_ preferCSSPageSize: Bool) -> PageProperties {
        self.preferCSSPageSize = preferCSSPageSize
        return self
    }

    public func addPrintBackground(_ printBackground: Bool) -> PageProperties {
        self.printBackground = printBackground
        return self
    }

    public func addLandscape(_ landscape: Bool) -> PageProperties {
        self.landscape = landscape
        return self
    }
    /// Merge alphanumerically the resulting PDFs
    /// e.g document_1.doc, document_2.csv, document_3.odt
    public func mergeFiles() -> PageProperties {
        self.merge = true
        return self
    }

    public func flattenDocuments() -> PageProperties {
        self.flatten = true
        return self
    }

    public func addScale(_ scale: Double) -> PageProperties {
        self.scale = scale
        return self
    }

    public func addNativePageRanges(start: Int, end: Int) throws -> PageProperties {
        guard start >= 1 && start < end else {
            throw GotenbergError.pageRangeInvalid
        }
        self.nativePageRanges = "\(start)-\(end)"
        return self
    }

    public func addPDFFormat(_ pdfFormat: PDFFormat) -> PageProperties {
        self.pdfFormat = pdfFormat
        return self
    }

    public func addPDFUniversalAccess(_ pdfUniversalAccess: Bool) -> PageProperties {
        self.pdfUniversalAccess = pdfUniversalAccess
        return self
    }

    public func addLosslessImageCompression(_ losslessCompression: Bool) -> PageProperties {
        self.losslessImageCompression = losslessCompression
        return self
    }
    /// if any of the documents from the input
    public func inputFilePassword(_ password: String) -> PageProperties {
        self.password = password
        return self
    }

    public func addIMagerQuality(_ quality: Int) -> PageProperties {
        self.quality = quality
        return self
    }

    public func reduceImageResolution(_ resolution: Bool) -> PageProperties {
        self.reduceImageResolution = resolution
        return self
    }

    public func addMetaData(_ metadata: Metadata) -> PageProperties {
        self.metadata = metadata
        return self
    }

    public func addMaxImageResolution(_ maxResolution: MaxImageResolution = .normal) -> PageProperties {
        self.maxImageResolution = maxResolution
        return self
    }

    public func build() throws -> PageProperties {
        self
    }

    internal var formValues: [String: String] {
        var values: [String: String] = [:]

        values["paperWidth"] = String(paperWidth)
        values["paperHeight"] = String(paperHeight)
        values["marginTop"] = String(marginTop)
        values["marginBottom"] = String(marginBottom)
        values["marginLeft"] = String(marginLeft)
        values["marginRight"] = String(marginRight)
        values["preferCSSPageSize"] = String(preferCSSPageSize)
        values["printBackground"] = String(printBackground)
        values["landscape"] = String(landscape)
        values["scale"] = String(scale)
        values["nativePageRanges"] = nativePageRanges
        values["pdfFormat"] = pdfFormat.rawValue
        values["pdfUniversalAccess"] = String(pdfUniversalAccess)

        if let headerHTML = headerHTML {
            values["headerHTML"] = headerHTML
        }

        if let footerHTML = footerHTML {
            values["footerHTML"] = footerHTML
        }

        if let waitDelay = waitDelay {
            values["waitDelay"] = String(waitDelay)
        }

        if let waitForExpression = waitForExpression {
            values["waitForExpression"] = waitForExpression
        }

        if let emulatedMediaType = emulatedMediaType {
            values["emulatedMediaType"] = emulatedMediaType.rawValue
        }

        values["flatten"] = String(flatten)
        values["merge"] = String(merge)
        values["losslessImageCompression"] = String(losslessImageCompression)
        values["quality"] = String(quality)
        values["reduceImageResolution"] = String(reduceImageResolution)
        values["maxImageResolution"] = maxImageResolution.rawValue.description

        if let metadata = metadata {
            do {
                let encoder = JSONEncoder()

                let formatter = DateFormatter()

                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss-SS:00"

                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)

                encoder.dateEncodingStrategy = .formatted(formatter)

                let data = try encoder.encode(metadata)
                if let stringValue = String(data: data, encoding: .utf8) {
                    values["metadata"] = stringValue
                }
            } catch {
                logger.error(
                    "Error serializing metadata",
                    metadata: [
                        "error": .string(error.localizedDescription)
                    ]
                )
            }
        }

        return values
    }

    private struct _PageProperties {
        static let paperWidth: Double = 8.5
        static let paperHeight: Double = 11
        static let marginTop: Double = 0.39
        static let marginBottom: Double = 0.39
        static let marginLeft: Double = 0.39
        static let marginRight: Double = 0.39
        static let preferCSSPageSize: Bool = false
        static let printBackground: Bool = false
        static let landscape: Bool = false
        static let scale: Double = 1.0
        static let nativePagerRanges: String = ""
        static let pdfFormat: PDFFormat = .A2B
        static let pdfUniversalAccess: Bool = false
    }

    public struct MaxImageResolution: Sendable {
        let rawValue: Resolution

        public static let lowest: MaxImageResolution = MaxImageResolution(rawValue: .lowest)

        public static let lower: MaxImageResolution = MaxImageResolution(rawValue: .lower)

        public static let normal: MaxImageResolution = MaxImageResolution(rawValue: .normal)

        public static let higher: MaxImageResolution = MaxImageResolution(rawValue: .higher)

        public static let highest: MaxImageResolution = MaxImageResolution(rawValue: .highest)

        enum Resolution: Int, CustomStringConvertible {
            case lowest = 75
            case lower = 150
            case normal = 300
            case higher = 600
            case highest = 1200

            var description: String {
                String(self.rawValue)
            }
        }
    }
}
