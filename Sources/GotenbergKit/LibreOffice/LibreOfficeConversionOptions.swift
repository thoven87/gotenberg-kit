//
//  LibreOfficeConversionOptions.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/14/25.
//

import Foundation
import Logging

import class Foundation.JSONEncoder

/// LibreOffice conversion options for Gotenberg
public struct LibreOfficeConversionOptions {
    /// Set the password for opening the source file.
    public var password: String?
    /// Set the paper orientation to landscape.
    public var landscape: Bool?
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
    /// Password for opening the resulting PDF
    public var userPassword: String?
    /// Password for full access on the resulting PDF
    public var ownerPassword: String?
    /// Files to embed in the generated PDF (for ZUGFeRD/Factur-X compliance)
    public var embeds: [String: Data]

    // ── Sheet layout (Calc/spreadsheets) ─────────────────────────────────────
    /// Ignore each sheet's paper size, print ranges, and shown/hidden status;
    /// force every sheet (including hidden sheets) onto exactly one page.
    /// Default false
    public var singlePageSheets: Bool

    // ── Native watermarks (LibreOffice — text only, applied during conversion) ─
    /// Single-line text watermark rendered behind document content during conversion.
    /// For image/PDF watermarks use the `watermark` post-processing field instead.
    public var nativeWatermarkText: String?

    /// Watermark text color as a decimal RGB integer. Default 8388223 (light grey).
    public var nativeWatermarkColor: Int?

    /// Watermark font size in points. 0 = auto-sized. Default 0.
    public var nativeWatermarkFontHeight: Int?

    /// Watermark rotation in TENTHS of a degree (e.g. 450 = 45°). Default 0.
    public var nativeWatermarkRotateAngle: Int?

    /// Font name for the watermark. Font must be installed in the Docker image.
    /// Default "Helvetica"
    public var nativeWatermarkFontName: String?

    /// Tiled (repeating pattern) text watermark rendered behind document content.
    public var nativeTiledWatermarkText: String?

    // ── Attachment metadata ───────────────────────────────────────────────────
    /// Per-file attachment metadata keyed by filename.
    /// Required by QPDF for PDF/A-3 and Factur-X/ZUGFeRD compliance.
    /// Keys must match filenames in the `embeds` dictionary.
    public var embedsMetadata: [String: EmbedAttachmentMetadata]?

    // ── Post-processing overlays (PDF engine after LibreOffice converts) ───────
    /// Apply a watermark (rendered BEHIND page content) via the PDF engine.
    public var watermark: OverlayOptions?

    /// Apply a stamp (rendered ON TOP OF page content) via the PDF engine.
    public var stamp: OverlayOptions?

    /// Rotate pages via the PDF engine after conversion.
    public var rotate: RotatePDFOptions?

    // ── PDF Viewer Preferences (LibreOffice only) ────────────────────────────
    /// How the PDF opens in viewer. 0=default, 1=outline visible, 2=thumbnails visible.
    /// Default 0
    public var initialView: Int

    /// The page number on which the PDF opens. Default 1.
    public var initialPage: Int

    /// Initial zoom. 0=default, 1=fit page, 2=fit width, 3=fit visible, 4=use zoom value.
    /// Default 0
    public var magnification: Int

    /// Initial zoom percentage; only used when magnification=4. Default 100.
    public var zoom: Int

    /// Page layout. 0=default, 1=single page, 2=one column, 3=two columns.
    /// Default 0
    public var pageLayout: Int

    /// Place the first page on the left in two-column layout. Default false.
    public var firstPageOnLeft: Bool

    /// Resize the viewer window to the first page's dimensions on open. Default false.
    public var resizeWindowToInitialPage: Bool

    /// Center the viewer window on screen on open. Default false.
    public var centerWindow: Bool

    /// Open the PDF in full-screen mode. Default false.
    public var openInFullScreenMode: Bool

    /// Display document title in the viewer title bar. Default true.
    public var displayPDFDocumentTitle: Bool

    /// Hide the viewer menu bar. Default false.
    public var hideViewerMenubar: Bool

    /// Hide the viewer toolbar. Default false.
    public var hideViewerToolbar: Bool

    /// Hide the viewer window controls. Default false.
    public var hideViewerWindowControls: Bool

    /// Use slide transition effects in Impress presentations. Default true.
    public var useTransitionEffects: Bool

    /// Number of bookmark levels visible on open. -1 = all levels. Default -1.
    public var openBookmarkLevels: Int

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
        landscape: Bool? = nil,
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
        flatten: Bool = false,
        userPassword: String? = nil,
        ownerPassword: String? = nil,
        embeds: [String: Data] = [:],
        singlePageSheets: Bool = false,
        nativeWatermarkText: String? = nil,
        nativeWatermarkColor: Int? = nil,
        nativeWatermarkFontHeight: Int? = nil,
        nativeWatermarkRotateAngle: Int? = nil,
        nativeWatermarkFontName: String? = nil,
        nativeTiledWatermarkText: String? = nil,
        embedsMetadata: [String: EmbedAttachmentMetadata]? = nil,
        watermark: OverlayOptions? = nil,
        stamp: OverlayOptions? = nil,
        rotate: RotatePDFOptions? = nil,
        initialView: Int = 0,
        initialPage: Int = 1,
        magnification: Int = 0,
        zoom: Int = 100,
        pageLayout: Int = 0,
        firstPageOnLeft: Bool = false,
        resizeWindowToInitialPage: Bool = false,
        centerWindow: Bool = false,
        openInFullScreenMode: Bool = false,
        displayPDFDocumentTitle: Bool = true,
        hideViewerMenubar: Bool = false,
        hideViewerToolbar: Bool = false,
        hideViewerWindowControls: Bool = false,
        useTransitionEffects: Bool = true,
        openBookmarkLevels: Int = -1
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
        self.userPassword = userPassword
        self.ownerPassword = ownerPassword
        self.embeds = embeds
        self.singlePageSheets = singlePageSheets
        self.nativeWatermarkText = nativeWatermarkText
        self.nativeWatermarkColor = nativeWatermarkColor
        self.nativeWatermarkFontHeight = nativeWatermarkFontHeight
        self.nativeWatermarkRotateAngle = nativeWatermarkRotateAngle
        self.nativeWatermarkFontName = nativeWatermarkFontName
        self.nativeTiledWatermarkText = nativeTiledWatermarkText
        self.embedsMetadata = embedsMetadata
        self.watermark = watermark
        self.stamp = stamp
        self.rotate = rotate
        self.initialView = initialView
        self.initialPage = initialPage
        self.magnification = magnification
        self.zoom = zoom
        self.pageLayout = pageLayout
        self.firstPageOnLeft = firstPageOnLeft
        self.resizeWindowToInitialPage = resizeWindowToInitialPage
        self.centerWindow = centerWindow
        self.openInFullScreenMode = openInFullScreenMode
        self.displayPDFDocumentTitle = displayPDFDocumentTitle
        self.hideViewerMenubar = hideViewerMenubar
        self.hideViewerToolbar = hideViewerToolbar
        self.hideViewerWindowControls = hideViewerWindowControls
        self.useTransitionEffects = useTransitionEffects
        self.openBookmarkLevels = openBookmarkLevels
    }

    /// Returns any overlay (watermark/stamp) files to be included in the
    /// multipart form alongside the documents being converted.
    var overlayFormFiles: [FormFile] {
        var files: [FormFile] = []
        if let watermark = watermark, let overlay = watermark.overlayFile {
            let mime: String
            let ext = (overlay.filename.split(separator: ".").last.map(String.init) ?? "").lowercased()
            switch ext {
            case "pdf": mime = "application/pdf"
            case "png": mime = "image/png"
            case "jpg", "jpeg": mime = "image/jpeg"
            case "webp": mime = "image/webp"
            default: mime = "application/octet-stream"
            }
            files.append(
                FormFile(
                    name: "watermark",
                    filename: overlay.filename,
                    contentType: mime,
                    data: overlay.data
                )
            )
        }
        if let stamp = stamp, let overlay = stamp.overlayFile {
            let mime: String
            let ext = (overlay.filename.split(separator: ".").last.map(String.init) ?? "").lowercased()
            switch ext {
            case "pdf": mime = "application/pdf"
            case "png": mime = "image/png"
            case "jpg", "jpeg": mime = "image/jpeg"
            case "webp": mime = "image/webp"
            default: mime = "application/octet-stream"
            }
            files.append(
                FormFile(
                    name: "stamp",
                    filename: overlay.filename,
                    contentType: mime,
                    data: overlay.data
                )
            )
        }
        return files
    }

    /// Convert options to form values for the API request
    var formValues: [String: String] {
        var values: [String: String] = [:]

        if let password = password {
            values["password"] = password
        }

        if let landscape = landscape {
            values["landscape"] = String(landscape)
        }

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
                    "Failed to serialize metadata",
                    metadata: [
                        "error": .string(error.localizedDescription)
                    ]
                )
            }
        }

        if let userPassword = userPassword {
            values["userPassword"] = userPassword
        }

        if let ownerPassword = ownerPassword {
            values["ownerPassword"] = ownerPassword
        }

        values["singlePageSheets"] = String(singlePageSheets)

        if let text = nativeWatermarkText {
            values["nativeWatermarkText"] = text
        }
        if let color = nativeWatermarkColor {
            values["nativeWatermarkColor"] = String(color)
        }
        if let fontHeight = nativeWatermarkFontHeight {
            values["nativeWatermarkFontHeight"] = String(fontHeight)
        }
        if let rotateAngle = nativeWatermarkRotateAngle {
            values["nativeWatermarkRotateAngle"] = String(rotateAngle)
        }
        if let fontName = nativeWatermarkFontName {
            values["nativeWatermarkFontName"] = fontName
        }
        if let tiledText = nativeTiledWatermarkText {
            values["nativeTiledWatermarkText"] = tiledText
        }

        if let embedsMeta = embedsMetadata, !embedsMeta.isEmpty {
            do {
                let data = try JSONEncoder().encode(embedsMeta)
                values["embedsMetadata"] = String(decoding: data, as: UTF8.self)
            } catch {
                logger.error(
                    "Failed to serialize embedsMetadata",
                    metadata: ["error": .string(error.localizedDescription)]
                )
            }
        }

        if let watermark = watermark {
            values.merge(watermark.formValues(for: "watermark")) { $1 }
        }
        if let stamp = stamp {
            values.merge(stamp.formValues(for: "stamp")) { $1 }
        }
        if let rotate = rotate {
            values.merge(rotate.formValues) { $1 }
        }

        // PDF Viewer Preferences
        values["initialView"] = String(initialView)
        values["initialPage"] = String(initialPage)
        values["magnification"] = String(magnification)
        values["zoom"] = String(zoom)
        values["pageLayout"] = String(pageLayout)
        values["firstPageOnLeft"] = String(firstPageOnLeft)
        values["resizeWindowToInitialPage"] = String(resizeWindowToInitialPage)
        values["centerWindow"] = String(centerWindow)
        values["openInFullScreenMode"] = String(openInFullScreenMode)
        values["displayPDFDocumentTitle"] = String(displayPDFDocumentTitle)
        values["hideViewerMenubar"] = String(hideViewerMenubar)
        values["hideViewerToolbar"] = String(hideViewerToolbar)
        values["hideViewerWindowControls"] = String(hideViewerWindowControls)
        values["useTransitionEffects"] = String(useTransitionEffects)
        values["openBookmarkLevels"] = String(openBookmarkLevels)

        return values
    }
}
