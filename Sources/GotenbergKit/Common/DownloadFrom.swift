//
//  DownloadFrom.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/23/25.
//

/// Download a file from a URL. It must return a Content-Disposition header with a filename parameter.
public struct DownloadFrom: Codable {
    /// URL to download a file from
    public var url: String
    /// HTTP headers for the file needed to download
    public var extraHttpHeaders: [String: String]? = nil
}
