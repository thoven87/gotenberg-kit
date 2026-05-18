//
//  DownloadFrom.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/23/25.
//

import Foundation

/// Instructs Gotenberg to fetch a file from a remote URL instead of uploading it directly.
///
/// The remote server **MUST** return a `Content-Disposition` header with a `filename` parameter
/// so Gotenberg knows what to call the file. AWS S3 users should set the `Content-Disposition`
/// metadata on their objects (e.g., `attachment; filename="doc.pdf"`).
public struct DownloadFrom: Codable, Sendable {

    /// Routes the downloaded file to a specific form field instead of the generic files array.
    ///
    /// - `nil` / empty  — regular file (added to the main files input)
    /// - `"embedded"`   — legacy alias for the `embeds` mechanism
    /// - `"watermark"`  — routes directly to the watermark post-processing slot
    /// - `"stamp"`      — routes directly to the stamp post-processing slot
    ///
    /// When set, `field` takes precedence over the deprecated `embedded` flag.
    public enum Field: String, Codable, Sendable {
        case embedded = "embedded"
        case watermark = "watermark"
        case stamp = "stamp"
    }

    /// URL of the file. The remote server MUST return a `Content-Disposition` header
    /// with a `filename` parameter.
    public var url: String

    /// Extra HTTP headers sent only when fetching this specific URL.
    public var extraHttpHeaders: [String: String]?

    /// Legacy embedding flag. Prefer `field = .embedded` for new code.
    /// Default false.
    public var embedded: Bool

    /// Routes the downloaded file to a specific form field.
    /// When set, takes precedence over `embedded`.
    public var field: Field?

    public init(
        url: String,
        extraHttpHeaders: [String: String]? = nil,
        embedded: Bool = false,
        field: Field? = nil
    ) {
        self.url = url
        self.extraHttpHeaders = extraHttpHeaders
        self.embedded = embedded
        self.field = field
    }
}
