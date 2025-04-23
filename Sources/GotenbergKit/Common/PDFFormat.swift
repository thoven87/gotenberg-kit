//
//  PDFFormat.swift
//  GotenbergKit
//
//  Created by Stevenson Michel on 4/1/25.
//

/// Various formats for document conversion.
public enum PDFFormat: String, Codable, Sendable {
    /// PDF/A-1a format
    @available(*, deprecated, message: "Deprecated in Gotenberg 8.x, see https://gotenberg.dev/docs/troubleshooting#pdfa-1a")
    case A1A = "PDF/A-1a"
    /// PDF/A-1b format
    case A1B = "PDF/A-1b"
    /// PDF/A-2b
    case A2B = "PDF/A-2b"
    /// PDF/A-3b
    case A3B = "PDF/A-3b"
}
