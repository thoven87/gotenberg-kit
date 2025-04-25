//
//  DownloadFrom.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/23/25.
//

/// Download a file from a URL. It must return a Content-Disposition header with a filename parameter.
public struct DownloadFrom: Codable {
    /// URL of the file. It MUST return a Content-Disposition header with a filename parameter.
    public var url: String
    /// The extra HTTP headers to send to the URL (JSON format).
    public var extraHttpHeaders: [String: String]? = nil
}
