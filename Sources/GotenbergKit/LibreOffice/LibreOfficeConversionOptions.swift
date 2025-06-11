//
//  LibreOfficeConversionOptions.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/11/25.
//

import Logging

import class Foundation.JSONEncoder

/// LibreOffice conversion options for Gotenberg
public struct LibreOfficeConversionOptions {
    /// Set the password for opening the source file.
    public var password: String?
    /// Set the paper orientation to landscape.
    /// Default false
    public var landscape: Bool
    /// Page ranges to print, e.g., '1-4' - empty means all pages.
    public var nativePageRanges: PageRange?
    //// Specify whether to update the indexes before conversion, keeping in mind that doing so might result in missing links in the final PDF.
    /// Default true
    public var updateIndexes: Bool
    /// Specify whether form fields are exported as widgets or only their fixed print representation is exported.
    /// Default true
    public var exportFormFields: Bool
    /// Specify whether multiple form fields exported are allowed to have the same field name.
    /// default false
    public var allowDuplicateFieldNames: Bool
    /// Specify if bookmarks are exported to PDF.
    /// Default false
    public var exportBookmarks: Bool
    /// Specify that the bookmarks contained in the source LibreOffice file should be exported to the PDF file as Named Destination.
    /// Default true
    public var exportBookmarksToPdfDestination: Bool
    /// Export the placeholders fields visual markings only. The exported placeholder is ineffective.
    /// Default false
    public var exportPlaceholders: Bool
    /// Specify if notes are exported to PDF.
    public var exportNotes: Bool
    /// Specify if notes pages are exported to PDF. Notes pages are available in Impress documents only.
    /// Default false
    public var exportNotesPages: Bool
    /// Specify, if the form field exportNotesPages is set to true, if only notes pages are exported to PDF.
    /// Default false
    public var exportOnlyNotesPages: Bool
    /// Specify if notes in margin are exported to PDF.
    /// Default false
    public var exportNotesInMargin: Bool
    /// Specify that the target documents with .od[tpgs] extension, will have that extension changed to .pdf when the link is exported to PDF. The source document remains untouched.
    /// Default false
    public var convertOooTargetToPdfTarget: Bool
    /// Specify that the file system related hyperlinks (file:// protocol) present in the document will be exported as relative to the source document location.
    /// Default false
    public var exportLinksRelativeFsys: Bool
    /// Export, for LibreOffice Impress, slides that are not included in slide shows.
    /// default false
    public var exportHiddenSlides: Bool
    /// Specify that automatically inserted empty pages are suppressed. This option is active only if storing Writer documents.
    /// default false
    public var skipEmptyPages: Bool
    /// Specify that a stream is inserted to the PDF file which contains the original document for archiving purposes.
    public var addOriginalDocumentAsStream: Bool
    /// Specify if images are exported to PDF using a lossless compression format like PNG or compressed using the JPEG format.
    /// default false
    public var losslessImageCompression: Bool
    /// Specify the quality of the JPG export. A higher value produces a higher-quality image and a larger file. Between 1 and 100.
    /// default 90
    public var quality: Int
    /// Specify if the resolution of each image is reduced to the resolution specified by the form field maxImageResolution.
    /// default false
    public var reduceImageResolution: Bool
    /// If the form field reduceImageResolution is set to true, tell if all images will be reduced to the given value in DPI. Possible values are: 75, 150, 300, 600 and 1200.
    public var maxImageResolution: Resolution
    /// Merge alphanumerically the resulting PDFs.
    /// default false
    public var merge: Bool
    /// Either intervals or pages.
    public var splitMode: SplitPDFOptions.SplitPDFMode?
    /// Either the intervals or the page ranges to extract, depending on the selected mode.
    /// e.g 1 or 1-3, 2-7
    public var splitSpan: String?
    /// Specify whether to put extracted pages into a single file or as many files as there are page ranges. Only works with pages mode.
    /// default false
    public var splitUnify: Bool

    /// Convert the resulting PDF into the given PDF/A format.
    public var pdfFormat: PDFFormat?
    /// Enable PDF for Universal Access for optimal accessibility.
    /// default false
    public var pdfua: Bool
    /// The metadata to write (JSON format).
    public var metadata: Metadata?
    /// Flatten the resulting PDF.
    /// default false
    public var flatten: Bool

    public struct PageRange {
        public let from: Int
        public let to: Int
    }

    public enum Resolution: Int, CustomStringConvertible {
        case lowest = 75
        case lower = 150
        case normal = 300
        case higher = 600
        case highest = 1200

        public var description: String {
            String(self.rawValue)
        }
    }

    private let logger = Logger(label: "com.gotenberkit.LibreOfficeConversionOptions")

    /// Initialize with default values
    public init(
        password: String? = nil,
        landscape: Bool = false,
        nativePageRanges: PageRange? = nil,
        updateIndexes: Bool = true,
        exportFormFields: Bool = true,
        allowDuplicateFieldNames: Bool = false,
        exportBookmarks: Bool = true,
        exportBookmarksToPdfDestination: Bool = false,
        exportPlaceholders: Bool = false,
        exportNotes: Bool = false,
        exportNotesPages: Bool = false,
        exportOnlyNotesPages: Bool = false,
        exportNotesInMargin: Bool = false,
        convertOooTargetToPdfTarget: Bool = false,
        exportLinksRelativeFsys: Bool = false,
        exportHiddenSlides: Bool = false,
        skipEmptyPages: Bool = false,
        addOriginalDocumentAsStream: Bool = false,
        losslessImageCompression: Bool = false,
        quality: Int = 90,
        reduceImageResolution: Bool = false,
        maxImageResolution: Resolution = .normal,
        merge: Bool = false,
        splitMode: SplitPDFOptions.SplitPDFMode? = nil,
        splitSpan: String? = nil,
        splitUnify: Bool = true,
        pdfFormat: PDFFormat? = nil,
        pdfua: Bool = false,
        metadata: Metadata? = nil,
        flatten: Bool = false
    ) {
        self.password = password
        self.landscape = landscape
        self.nativePageRanges = nativePageRanges
        self.updateIndexes = updateIndexes
        self.exportFormFields = exportFormFields
        self.allowDuplicateFieldNames = allowDuplicateFieldNames
        self.exportBookmarks = exportBookmarks
        self.exportBookmarksToPdfDestination = exportBookmarksToPdfDestination
        self.exportPlaceholders = exportPlaceholders
        self.exportNotes = exportNotes
        self.exportNotesPages = exportNotesPages
        self.exportOnlyNotesPages = exportOnlyNotesPages
        self.exportNotesInMargin = exportNotesInMargin
        self.convertOooTargetToPdfTarget = convertOooTargetToPdfTarget
        self.exportLinksRelativeFsys = exportLinksRelativeFsys
        self.exportHiddenSlides = exportHiddenSlides
        self.skipEmptyPages = skipEmptyPages
        self.addOriginalDocumentAsStream = addOriginalDocumentAsStream
        self.losslessImageCompression = losslessImageCompression
        self.quality = quality
        self.reduceImageResolution = reduceImageResolution
        self.maxImageResolution = maxImageResolution
        self.merge = merge
        self.splitMode = splitMode
        self.splitSpan = splitSpan
        self.splitUnify = splitUnify
        self.pdfFormat = pdfFormat
        self.pdfua = pdfua
        self.metadata = metadata
        self.flatten = flatten
    }

    /// Convert options to form values for the API request
    var formValues: [String: String] {
        var values: [String: String] = [:]

        if let password = password {
            values["password"] = password
        }

        values["landscape"] = String(landscape)

        if let nativePageRanges = nativePageRanges {
            values["nativePageRanges"] = "\(nativePageRanges.from)-\(nativePageRanges.to)"
        }

        values["updateIndexes"] = String(updateIndexes)

        values["exportFormFields"] = String(exportFormFields)

        values["allowDuplicateFieldNames"] = String(allowDuplicateFieldNames)
        values["exportBookmarks"] = String(exportBookmarks)

        values["exportBookmarksToPdfDestination"] = String(exportBookmarksToPdfDestination)

        values["exportPlaceholders"] = String(exportPlaceholders)

        values["exportNotes"] = String(exportNotes)

        values["exportNotesPages"] = String(exportNotesPages)

        values["exportOnlyNotesPages"] = String(exportOnlyNotesPages)

        values["exportNotesInMargin"] = String(exportNotesInMargin)

        values["convertOooTargetToPdfTarget"] = String(convertOooTargetToPdfTarget)

        values["exportLinksRelativeFsys"] = String(exportLinksRelativeFsys)

        values["exportHiddenSlides"] = String(exportHiddenSlides)

        values["skipEmptyPages"] = String(skipEmptyPages)

        values["addOriginalDocumentAsStream"] = String(addOriginalDocumentAsStream)

        values["losslessImageCompression"] = String(losslessImageCompression)

        values["quality"] = String(quality)

        values["reduceImageResolution"] = String(reduceImageResolution)

        values["maxImageResolution"] = maxImageResolution.description

        values["merge"] = String(merge)

        if let splitMode = splitMode {
            values["splitMode"] = splitMode.rawValue
            values["splitUnify"] = splitUnify.description
        }

        if let splitSpan = splitSpan {
            values["splitSpan"] = splitSpan.description
        }

        if let pdfFormat = pdfFormat {
            values["pdfa"] = pdfFormat.rawValue
        }

        values["pdfua"] = String(pdfua)

        values["flatten"] = String(flatten)

        if let metadata = metadata {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .formatted(Metadata.dateFormatter())

                let data = try encoder.encode(metadata)
                values["metadata"] = String(decoding: data, as: UTF8.self)
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
}
