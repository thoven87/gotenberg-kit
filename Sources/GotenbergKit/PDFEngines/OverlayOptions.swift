//
//  OverlayOptions.swift
//  gotenberg-kit
//
//  Shared options for stamp (/forms/pdfengines/stamp) and
//  watermark (/forms/pdfengines/watermark) operations.
//
//  Stamp  → rendered ON TOP  of page content (foreground overlay).
//  Watermark → rendered BEHIND page content (background underlay).
//

import struct Foundation.Data
import class Foundation.JSONEncoder

/// The source type for a stamp or watermark.
public enum OverlaySourceType: String, Sendable {
    /// Plain text rendered by the engine.
    case text = "text"
    /// An image file uploaded alongside the PDFs.
    case image = "image"
    /// A PDF page used as the overlay.
    case pdf = "pdf"
}

/// Options common to both stamp and watermark operations.
public struct OverlayOptions: Sendable {

    /// What kind of overlay to apply.
    public var sourceType: OverlaySourceType

    /// For `.text`: the text to render.
    /// For `.image` / `.pdf`: the **exact filename** of the uploaded overlay file
    /// (must match `overlayFile.filename`).
    public var expression: String

    /// Page ranges to apply the overlay to, e.g. "1-3,5".
    /// Omit or leave nil to apply to all pages.
    public var pages: String?

    /// Advanced styling options serialised as JSON.
    /// Supported keys: font, points, color, rotation, opacity, scale, offset.
    /// Engine-dependent (pdfcpu by default).
    public var styleOptions: [String: String]?

    /// The overlay file to upload (required for `.image` and `.pdf` source types).
    public var overlayFile: (filename: String, data: Data)?

    public init(
        sourceType: OverlaySourceType,
        expression: String,
        pages: String? = nil,
        styleOptions: [String: String]? = nil,
        overlayFile: (filename: String, data: Data)? = nil
    ) {
        self.sourceType = sourceType
        self.expression = expression
        self.pages = pages
        self.styleOptions = styleOptions
        self.overlayFile = overlayFile
    }

    /// Builds the form field dictionary for the given overlay kind ("stamp" or "watermark").
    func formValues(for kind: String) -> [String: String] {
        var v: [String: String] = [:]
        v["\(kind)Source"] = sourceType.rawValue
        v["\(kind)Expression"] = expression
        if let pages = pages { v["\(kind)Pages"] = pages }
        if let opts = styleOptions,
            let data = try? JSONEncoder().encode(opts),
            let json = String(data: data, encoding: .utf8)
        {
            v["\(kind)Options"] = json
        }
        return v
    }
}
