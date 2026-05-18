//
//  EmbedAttachmentMetadata.swift
//  gotenberg-kit
//
//  Per-attachment metadata for the `embedsMetadata` form field.
//  Required by QPDF for PDF/A-3 and Factur-X / ZUGFeRD compliance.
//  PDF/A-1b and PDF/A-2b do NOT support attachments — use PDF/A-3b.
//

import Foundation

/// Metadata for a single embedded file attachment in a PDF.
///
/// Pass a `[String: EmbedAttachmentMetadata]` dictionary as `embedsMetadata`
/// on Chromium or LibreOffice options when you also supply `embeds` files.
/// Keys must match the filenames used in the `embeds` dictionary exactly.
public struct EmbedAttachmentMetadata: Codable, Sendable {

    /// The `/AFRelationship` value written to the PDF attachment stream.
    public enum Relationship: String, Codable, Sendable {
        /// The embedded file is the source material for this PDF.
        case source = "Source"
        /// The embedded file is data associated with this PDF.
        case data = "Data"
        /// The embedded file is an alternative representation of this PDF.
        case alternative = "Alternative"
        /// The embedded file supplements the PDF content.
        case supplement = "Supplement"
        /// Relationship not specified.
        case unspecified = "Unspecified"
    }

    /// MIME type written to the embedded file stream's `/Subtype` entry.
    /// e.g. `"application/xml"` for a Factur-X invoice.
    public var mimeType: String

    /// PDF `/AFRelationship` value. Required by QPDF for Factur-X/ZUGFeRD compliance.
    public var relationship: Relationship

    public init(mimeType: String, relationship: Relationship = .unspecified) {
        self.mimeType = mimeType
        self.relationship = relationship
    }

    // MARK: - Common presets

    /// Factur-X / ZUGFeRD XML invoice attachment metadata.
    public static func zugferdXML(relationship: Relationship = .data) -> EmbedAttachmentMetadata {
        EmbedAttachmentMetadata(mimeType: "application/xml", relationship: relationship)
    }
}
